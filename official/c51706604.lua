--ブリザード
--Blizzard
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsSpell() and c:IsNegatableSpellTrap()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local c=e:GetHandler()
		--continous negation
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetCondition(s.discon)
		e1:SetOperation(s.disop)
		e1:SetLabel(tc:GetOriginalCodeRule())
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		--redirect
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD_EXC_GRAVE|RESET_PHASE|PHASE_END)
		e2:SetCondition(s.recon)
		e2:SetValue(LOCATION_HAND)
		tc:RegisterEffect(e2,true)
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	local code1,code2=re:GetHandler():GetOriginalCodeRule()
	return re:IsSpellEffect() and loc&LOCATION_ONFIELD~=0 and (code1==code or code2==code)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.NegateEffect(ev)
end
function s.recon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:GetDestination()==LOCATION_GRAVE
end