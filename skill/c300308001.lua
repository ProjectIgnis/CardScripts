--Straight out of Neo Space!
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	--At the start of the Duel, flip this card over
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ELEMENTAL_HERO,SET_NEO_SPACIAN}
s.listed_names={CARD_NEOS}
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--If only your opponent controls a monster, you can Special Summon 1 "Elemental HERO Neos" from your hand, also for the rest of this turn, you cannot Special Summon, except "Elemental HERO" or "Neo-Spacian" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(s.handspcon)
	e1:SetOperation(s.handspop)
	Duel.RegisterEffect(e1,tp)
	--During your End Phase, if a Fusion Monster you control is returned to your Extra Deck, you can Special Summon 1 "Elemental HERO Neos" from your Deck
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(s.deckspcon)
	e2:SetOperation(s.deckspop)
	Duel.RegisterEffect(e2,tp)
end
function s.spfilter(c,e,tp)
	return c:IsCode(CARD_NEOS) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.handspcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
end
function s.handspop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
	--For the rest of this turn, you cannot Special Summon, except "Elemental HERO" or "Neo-Spacian" monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not c:IsSetCard({SET_ELEMENTAL_HERO,SET_NEO_SPACIAN}) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.deckspconfilter(c,tp)
	return c:IsFusionMonster() and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function s.deckspcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsEndPhase(tp) and eg:IsExists(s.deckspconfilter,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
end
function s.deckspop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
