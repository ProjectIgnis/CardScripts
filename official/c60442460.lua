--導かれし烙印
--Branded Befallen
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Banish 1 LIGHT or DARK monster from either GY and negate an activated effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_BYSTIAL}
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not (ep==1-tp and Duel.IsChainDisablable(ev)) or re:GetHandler():IsDisabled() then return false end
	local ch=Duel.GetCurrentChain(true)-1
	if ch>0 then
		local cplayer=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_CONTROLER)
		local ceff=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_EFFECT)
		if cplayer==tp and ceff:GetHandler():IsSetCard(SET_BYSTIAL) and ceff:IsMonsterEffect() then
			return true
		end
	end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if #g~=1 then return false end
	local tc=g:GetFirst()
	return tc:IsSetCard(SET_BYSTIAL) and tc:IsControler(tp) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup()
end
function s.rmvfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and c:IsAbleToRemove() and aux.SpElimFilter(c,true)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and s.rmvfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmvfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmvfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		Duel.NegateEffect(ev)
	end
end