--Great Swarm Guardian
--designed by Nitrogames#8002, scripted by Naim
function c210777072.initial_effect(c)
	--sssummon from hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(210777072,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c210777072.sscond)
	e1:SetTarget(c210777072.sstg)
	e1:SetOperation(c210777072.ssop)
	c:RegisterEffect(e1)
	--tohand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(210777072,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,210777072)
	e2:SetCondition(c210777072.thcond)
	e2:SetTarget(c210777072.thtg)
	e2:SetOperation(c210777072.thop)
	c:RegisterEffect(e2)
	--spsummon (when sent from gy)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(210777072,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCost(c210777072.spcost)
	e3:SetTarget(c210777072.sptg)
	e3:SetOperation(c210777072.spop)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(210777072,ACTIVITY_CHAIN,c210777072.chainfilter)
end
function c210777072.ssfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0xf11) and c:IsPreviousLocation(LOCATION_MZONE)
end
function c210777072.sscond(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c210777072.ssfilter,1,nil,tp)
end
function c210777072.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,186,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c210777072.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,186,tp,tp,false,false,POS_FACEUP)
	end
end
function c210777072.thcond(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0xf11)
end
function c210777072.thfilter(c)
	return (c:IsSetCard(0xf11)) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c210777072.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c210777072.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c210777072.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c210777072.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c210777072.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function c210777072.chainfilter(re,tp,cid)
	return not (re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0xf11) and re:GetHandler():GetLocation()==LOCATION_GRAVE)
end
function c210777072.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(210777072,tp,ACTIVITY_CHAIN)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c210777074.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c210777072.aclimit(e,re,tp)
	local loc=re:GetActivateLocation()
	return  re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0xf11) and not loc==LOCATION_GRAVE	
end
function c210777072.spfilter(c,e,tp)
	return c:IsSetCard(0xf11) and c:IsCanBeSpecialSummoned(e,186,tp,false,false)
	--186: is what i'm using to register "Special Summoned by a "Great Swarm" Card
end
function c210777072.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c210777072.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c210777072.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c210777072.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,186,tp,tp,false,false,POS_FACEUP)
	end
end
