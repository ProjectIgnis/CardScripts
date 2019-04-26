--Zefraath - Ascended
--AlphaKretin
function c210210500.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xc4),3)
	--alt link summon, credit to andre
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4021,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(c210210500.alcondition)
	e1:SetTarget(c210210500.altarget)
	e1:SetOperation(c210210500.aloperation)
	e1:SetValue(SUMMON_TYPE_LINK)
	c:RegisterEffect(e1)
	--open zones
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c210210500.lzcon)
	e2:SetOperation(c210210500.lzop)
	c:RegisterEffect(e2)
end
function c210210500.LConditionFilter(c,lc,tp)
	return c:IsFaceup() and c:IsCanBeLinkMaterial(lc,tp) and c:IsCode(29432356)
end
function c210210500.LCheck(c,tp,sg,mg,lc)
	sg:AddCard(c)
	local res=c210210500.LCheckGoal(tp,sg,lc)
	sg:RemoveCard(c)
	return res
end
function c210210500.LCheckGoal(tp,sg,lc)
	return Duel.GetLocationCountFromEx(tp,tp,sg,lc)>0
end
function c210210500.alcondition(e,c)
	if c==nil then return true end
	if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
	local tp=c:GetControler()
	local mg=Duel.GetMatchingGroup(c210210500.LConditionFilter,tp,LOCATION_MZONE,0,nil,c,tp)
	local sg=Group.CreateGroup()
	return mg:IsExists(c210210500.LCheck,1,nil,tp,sg,mg,c)
end
function c210210500.altarget(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local mg=Duel.GetMatchingGroup(c210210500.LConditionFilter,tp,LOCATION_MZONE,0,nil,c,tp)
	local sg=Group.CreateGroup()
	local cancel=false
	while sg:GetCount()<1 do
		local cg=mg:Filter(c210210500.LCheck,sg,tp,sg,mg,c)
		if cg:GetCount()==0 then break end
		if sg:GetCount()==1 and c210210500.LCheckGoal(tp,sg,lc) then
			cancel=true
		else
			cancel=false
		end
		local tc=Group.SelectUnselect(cg,sg,tp,cancel,sg:GetCount()==0 or cancel,1,1)
		if not tc then break end
		if not sg:IsContains(tc) then
			sg:AddCard(tc)
		else
			sg:RemoveCard(tc)
		end
	end
	if sg:GetCount()>0 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function c210210500.aloperation(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	Duel.SendtoGrave(g,REASON_MATERIAL+REASON_LINK)
	g:DeleteGroup()
end
function c210210500.lzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c210210500.lzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_BECOME_LINKED_ZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(0x1f)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c210210500.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function c210210500.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0xc4)
end