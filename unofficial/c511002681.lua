--Performage Magic Tactician
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63251695,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--replace
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21501505,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.repcon)
	e1:SetCost(s.repcost)
	e1:SetTarget(s.reptg)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
	--Double Snare
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCode(3682106)
	c:RegisterEffect(e3)
end
function s.tgfilter(c,tp)
	return c:IsLocation(LOCATION_SZONE) and c:IsControler(tp) and c:GetSequence()<5
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(s.tgfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lc=Duel.GetFieldCard(tp,LOCATION_SZONE,6)
	local rc=Duel.GetFieldCard(tp,LOCATION_SZONE,7)
	if chk==0 then return (not lc or lc:IsDestructable()) and (not rc or rc:IsDestructable()) end
	local g=Group.FromCards(lc,rc)
	Duel.Destroy(g,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function s.repcon(e,tp,eg,ep,ev,re,r,rp)
	if e==re or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or #g~=1 then return false end
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	return tc:IsOnField() and tc:IsLocation(LOCATION_MZONE)
end
function s.cfilter(c,tp,re,rp,tf,ceg,cep,cev,cre,cr,crp,tc)
	return c:IsAbleToGraveAsCost() 
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,c,re,rp,tf,ceg,cep,cev,cre,cr,crp,tc)
end
function s.filter(c,re,rp,tf,ceg,cep,cev,cre,cr,crp,tc)
	return tf(re,rp,ceg,cep,cev,cre,cr,crp,0,c) and c~=tc
end
function s.repcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local tf=re:GetTarget()
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	local res,ceg,cep,cev,cre,cr,crp=Duel.CheckEvent(re:GetCode(),true)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp,re,rp,tf,ceg,cep,cev,cre,cr,crp,tc)
		and c:IsAbleToGraveAsCost() end
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,re,rp,tf,ceg,cep,cev,cre,cr,crp,tc)
	g:AddCard(c)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tf=re:GetTarget()
	local res,ceg,cep,cev,cre,cr,crp=Duel.CheckEvent(re:GetCode(),true)
	local tc=e:GetLabelObject()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,re,rp,tf,ceg,cep,cev,cre,cr,crp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,tc,re,rp,tf,ceg,cep,cev,cre,cr,crp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,tc,re,rp,tf,ceg,cep,cev,cre,cr,crp)
	e:SetLabelObject(nil)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.ChangeTargetCard(ev,Group.FromCards(tc))
	end
end
