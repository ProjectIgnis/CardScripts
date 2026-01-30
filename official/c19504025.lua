--糾罪巧－再巧
--Enneacraft Reset
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Place 1 "Enneapolis" from your Deck or GY face-up in your Field Zone, or if you control "Enneapolis", you can negate the effects of face-up cards your opponent controls up to the number of cards in your Pendulum Zones instead
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--If your opponent activates a card or effect while this card is in your GY: You can banish this card; change "Enneacraft" monsters you control to face-down Defense Position up to the number of cards in your Pendulum Zones
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==1-tp end)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
s.listed_names={17621695} --"Enneapolis"
s.listed_series={SET_ENNEACRAFT}
function s.plfilter(c)
	return c:IsCode(17621695) and not c:IsForbidden()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local disable_chk=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,17621695),tp,LOCATION_ONFIELD,0,1,nil)
			and Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)>0
			and Duel.IsExistingMatchingCard(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil)
		return disable_chk or Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local place_chk=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.plfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	local pzone_card_count=Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)
	local disable_chk=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,17621695),tp,LOCATION_ONFIELD,0,1,nil)
		and pzone_card_count>0
		and Duel.IsExistingMatchingCard(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil)
	local op=1
	if disable_chk then
		op=Duel.SelectEffect(tp,
			{place_chk,aux.Stringid(id,2)},
			{disable_chk,aux.Stringid(id,3)})
	end
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.plfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil):GetFirst()
		if sc then
			Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		end
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
		local g=Duel.SelectMatchingCard(tp,Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,pzone_card_count,nil)
		if #g==0 then return end
		Duel.HintSelection(g)
		local c=e:GetHandler()
		for sc in g:Iter() do
			--Negate their effects
			sc:NegateEffects(c,nil,true)
		end
	end
end
function s.posfilter(c)
	return c:IsSetCard(SET_ENNEACRAFT) and c:IsCanTurnSet()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)>0
		and Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,POS_FACEDOWN_DEFENSE)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local max_count=Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)
	if max_count==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,0,1,max_count,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end