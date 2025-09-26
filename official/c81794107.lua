--
--R.B. Lambda Cannon
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "R.B." monster from your GY to your hand, except "R.B. Lambda Cannon"
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_TOHAND)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetCountLimit(1,id)
	e1a:SetTarget(s.thtg)
	e1a:SetOperation(s.thop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--Destroy this card, and if you do, look at your opponent's hand, then you can Special Summon 1 monster from it to their field, but negate its effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.descon)
	e2:SetCost(Cost.PayLP(1200))
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_RB}
function s.thfilter(c)
	return c:IsSetCard(SET_RB) and c:IsMonster() and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
	end
end
function s.desconfilter(c,ec,lg)
	return c:IsSetCard(SET_RB) and c:IsLinkMonster() and c:IsFaceup() and (lg:IsContains(c) or c:GetLinkedGroup():IsContains(ec))
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(s.desconfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c,c:GetLinkedGroup())
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_HAND)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #hg==0 then return end
	Duel.ConfirmCards(tp,hg)
	local sg=hg:Filter(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false,POS_FACEUP,1-tp)
	if #sg==0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return Duel.ShuffleHand(1-tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=sg:Select(tp,1,1,nil):GetFirst()
	if not sc then return end
	Duel.BreakEffect()
	if Duel.SpecialSummonStep(sc,0,tp,1-tp,false,false,POS_FACEUP) then
		--Negate its effects
		sc:NegateEffects(c)
	end
	Duel.SpecialSummonComplete()
	Duel.ShuffleHand(1-tp)
end