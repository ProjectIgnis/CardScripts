--道化の一座 ハット
--Clown Crew Hat
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--During your Main Phase: You can send 1 "Clown Crew" card from your Deck to your GY, except a Pendulum Monster, and if you do, Special Summon this card, also you cannot activate the effects of monsters Special Summoned from the Deck or Extra Deck until the end of the next turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(s.gytg)
	e1:SetOperation(s.gyop)
	e1:SetCountLimit(1,{id,0})
	c:RegisterEffect(e1)
	--Monsters your opponent controls lose 1500 DEF while you control a Tribute Summoned monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(function(e) return Duel.IsExistingMatchingCard(Card.IsTributeSummoned,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) end)
	e2:SetValue(-1500)
	c:RegisterEffect(e2)
	--If this card is Tributed: You can activate 1 of these effects (but you can only use each of these effects of "Clown Crew Hat" once per turn);
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_RELEASE)
	e3:SetTarget(s.efftg)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_CLOWN_CREW}
function s.gyfilter(c)
	return c:IsSetCard(SET_CLOWN_CREW) and not c:IsPendulumMonster() and c:IsAbleToGrave()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	--You cannot activate the effects of monsters Special Summoned from the Deck or Extra Deck until the end of the next turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.actval)
	e1:SetReset(RESET_PHASE|PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
end
function s.actval(e,re,tp)
	local rc=re:GetHandler()
	return re:IsMonsterEffect() and rc:IsLocation(LOCATION_MZONE) and rc:IsSummonLocation(LOCATION_DECK|LOCATION_EXTRA)
end
function s.spfilter(c,e,tp)
	if c:IsLocation(LOCATION_DECK) and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)<=0 then return false end
	return c:IsSetCard(SET_CLOWN_CREW) and c:IsMonster() and not c:IsPendulumMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsPendulumMonster,Card.IsFaceup,Card.IsAbleToDeck),tp,LOCATION_MZONE|LOCATION_EXTRA,LOCATION_MZONE|LOCATION_EXTRA,1,nil)
	local b2=not Duel.HasFlagEffect(tp,id+100)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,3)},
		{b2,aux.Stringid(id,4)})
	e:SetLabel(op)
	if op==1 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_TODECK)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_MZONE|LOCATION_EXTRA)
	elseif op==2 then
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--● Shuffle all Pendulum Monsters on the field and face-up Extra Decks into the Deck
		local g=Duel.GetMatchingGroup(aux.AND(Card.IsPendulumMonster,Card.IsFaceup,Card.IsAbleToDeck),tp,LOCATION_MZONE|LOCATION_EXTRA,LOCATION_MZONE|LOCATION_EXTRA,nil)
		if #g>0 then
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	elseif op==2 then
		--● Special Summon 1 non-Pendulum "Clown Crew" monster from your Deck or Extra Deck, ignoring its Summoning conditions
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end