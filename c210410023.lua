--created & coded by Lyris, art by Animekidky of DeviantArt
--復剣主ティべリウス
function c210410023.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c210410023.val)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetTarget(c210410023.target)
	e3:SetOperation(c210410023.operation)
	c:RegisterEffect(e3)
end
function c210410023.val(e,c)
	return Duel.GetMatchingGroupCount(c210410023.rfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,LOCATION_GRAVE,nil)*100
end
function c210410023.rfilter(c)
	return c:IsSetCard(0xfb2) and c:IsType(TYPE_MONSTER)
end
function c210410023.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c210410023.spfilter(c)
	return c:IsSetCard(0xfb2) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c210410023.cfilter(c)
	return c:IsSetCard(0xfb2) and c:IsType(TYPE_MONSTER)
end
function c210410023.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMatchingGroupCount(c210410023.cfilter,tp,LOCATION_GRAVE,0,e:GetHandler())==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210410023.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
