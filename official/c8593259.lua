--Ｅ・ＨＥＲＯ クレイ・ガードマン
--Elemental HERO Clay Guardian
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 "Elemental HERO" monster + 1 Warrior monster
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_ELEMENTAL_HERO),aux.FilterBoolFunctionEx(Card.IsRace,RACE_WARRIOR))
	--If this card is Special Summoned: You can Special Summon 1 "Elemental HERO" monster from your Deck, then if your opponent controls a card, you can inflict 400 damage to your opponent for each, also you cannot Special Summon from the Extra Deck for the rest of this turn, except "HERO" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Other "Elemental HERO" monsters you control cannot be destroyed by battle or card effects
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetTargetRange(LOCATION_MZONE,0)
	e2a:SetTarget(function(e,c) return c:IsSetCard(SET_ELEMENTAL_HERO) and c~=e:GetHandler() end)
	e2a:SetValue(1)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2b)
end
s.listed_series={SET_HERO,SET_ELEMENTAL_HERO}
s.material_setcode={SET_HERO,SET_ELEMENTAL_HERO}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ELEMENTAL_HERO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,400*Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD))
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local dam=400*Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
			Duel.BreakEffect()
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
	--You cannot Special Summon from the Extra Deck for the rest of this turn, except "HERO" monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_HERO) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end