--Metalfoes Zirconia
--scripted by Naim
function c210777041.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunction(Card.IsType,TYPE_FUSION),1,aux.FilterBoolFunctionEx(Card.IsSetCard,0xe1),2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(c210777041.target)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(210777041,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c210777041.destg)
	e2:SetOperation(c210777041.desop)
	c:RegisterEffect(e2)
	--search when leaving
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(210777041,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetTarget(c210777041.thtg)
	e4:SetOperation(c210777041.thop)
	c:RegisterEffect(e4)
end
function c210777041.target(e,c)
	return c:IsSetCard(0xe1)
end
function c210777041.filter(c)
	return c:IsFaceup()
end
function c210777041.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then	return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,0,1,nil)
		and	Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil)	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
end
function c210777041.desop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	local g2=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
	g1:Merge(g2)
	if g1:GetCount()>0 then
		Duel.HintSelection(g1)
		Duel.Destroy(g1,REASON_EFFECT)
	end
end
function c210777041.filter1(c)
	return c:IsAbleToHand() and c:IsSetCard(0xe1) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function c210777041.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210777041.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		and Duel.IsExistingMatchingCard(c210777041.filter1,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_DECK)
end
function c210777041.thop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(c210777041.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	local g2=Duel.GetMatchingGroup(c210777041.filter1,tp,LOCATION_EXTRA,0,nil)
	if g1:GetCount()>0 and g2:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg1=g1:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg2=g2:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		Duel.SendtoHand(sg1,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg1)
	end
end
