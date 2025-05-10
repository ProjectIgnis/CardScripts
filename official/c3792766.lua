--トリックスター・デビルフィニウム
--Trickstar Delfiendium
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2+ "Trickstar" monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_TRICKSTAR),2)
	--Add banished "Trickstar" cards to your hand, and if you do, this card gains 1000 ATK for each card added
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_TRICKSTAR}
function s.lkfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_TRICKSTAR)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLinkedGroup():IsExists(s.lkfilter,1,nil)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_TRICKSTAR) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_MZONE,1,nil,TYPE_LINK) end
	local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_MZONE,nil,TYPE_LINK)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED,0,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,#g*1000)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rg=Duel.GetTargetCards(e)
	Duel.SendtoHand(rg,nil,REASON_EFFECT)
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_HAND)
		if ct>0 then
			--This card gains 1000 ATK for each card added
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
			e1:SetValue(ct*1000)
			c:RegisterEffect(e1)
		end
	end
end