--転生炎獣の聖域
--Salamangreat Sanctuary
--fixed by Larry126 and MLD
local s,id,alias=GetID()
function s.initial_effect(c)
	alias=c:GetOriginalCodeRule()
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--extra material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(alias,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.linkcon)
	e2:SetTarget(s.linktg)
	e2:SetOperation(s.linkop)
	e2:SetValue(SUMMON_TYPE_LINK)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,alias)
	e3:SetTargetRange(LOCATION_EXTRA,0)
	e3:SetTarget(s.mattg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--recover
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(alias,1))
	e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,alias+100)
	e4:SetCondition(s.condition)
	e4:SetCost(s.cost)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
s.listed_series={0x119}
function s.lmfilter(c,lc,tp)
	return c:IsFaceup() and c:IsCode(lc:GetCode()) and c:IsCanBeLinkMaterial(lc,tp)
end
function s.linkcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.lmfilter,tp,LOCATION_MZONE,0,nil,c,tp)
	local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,g,REASON_LINK)
	return ((#mustg==1 and s.lmfilter(mustg:GetFirst(),c,tp)) or (#mustg==0 and #g>0))
		and Duel.GetFlagEffect(tp,alias)==0 and Duel.GetLocationCountFromEx(tp,tp,g,c)>0
end
function s.linktg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.lmfilter,tp,LOCATION_MZONE,0,nil,c,tp)
	local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,g,REASON_LINK)
	if #mustg>0 then
		mustg:KeepAlive()
		e:SetLabelObject(mustg)
		return true
	end
	local tc=g:SelectUnselect(Group.CreateGroup(),tp,true,true)
	if tc then
		local sg=Group.FromCards(tc)
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function s.linkop(e,tp,eg,ep,ev,re,r,rp,c)
	local mg=e:GetLabelObject()
	c:SetMaterial(mg)
	Duel.SendtoGrave(mg,REASON_MATERIAL+REASON_LINK)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.mattg(e,c)
	return c:IsSetCard(0x119) and c:IsLinkMonster()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	return Duel.GetBattleDamage(tp)>0 and (Duel.GetAttacker():IsSetCard(0x119) or (d and d:IsSetCard(0x119)))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.filter(c)
	return aux.nzatk(c) and c:IsLinkMonster() and c:IsSetCard(0x119)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tg=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,tg:GetFirst():GetAttack())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and aux.nzatk(tc) and tc and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if not tc:IsImmuneToEffect(e1) and tc:GetAttack()==0 then
			Duel.Recover(tp,tc:GetBaseAttack(),REASON_EFFECT)
		end
	end
end
