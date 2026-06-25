--大魔女サンドリヨン
--Witchcrafter Madame Rilliona
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: "Witchcrafter Madame Verre" + 2 Spellcaster monsters
	Fusion.AddProcMixN(c,true,true,21522601,1,aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER),2)
	--If this card is Fusion Summoned: You can Special Summon up to 3 Level 7 or lower "Witchcrafter" monsters with different Attributes from each other from your hand and/or Deck, also you cannot Special Summon from the Extra Deck for the rest of this turn, except Fusion Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e) return e:GetHandler():IsFusionSummoned() end)
	e1:SetTarget(s.witchsptg)
	e1:SetOperation(s.witchspop)
	c:RegisterEffect(e1)
	--During your End Phase, if this card is in your GY: You can reveal 1 Spell in your hand; Special Summon this card in Defense Position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e2:SetCost(Cost.Reveal(Card.IsSpell))
	e2:SetTarget(s.selfsptg)
	e2:SetOperation(s.selfspop)
	c:RegisterEffect(e2)
end
s.listed_names={21522601} --"Witchcrafter Madame Verre"
s.listed_series={SET_WITCHCRAFTER}
s.material_setcode=SET_WITCHCRAFTER
function s.witchspfilter(c,e,tp)
	return c:IsLevelBelow(7) and c:IsSetCard(SET_WITCHCRAFTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.witchsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.witchspfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.witchspop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.GetMatchingGroup(s.witchspfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil,e,tp)
	if ft>0 and #g>0 then
		local attr_count=g:GetClassCount(Card.GetAttribute)
		ft=math.min(ft,3,attr_count)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,aux.dpcheck(Card.GetAttribute),1,tp,HINTMSG_SPSUMMON)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	--You cannot Special Summon from the Extra Deck for the rest of this turn, except Fusion Monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsFusionMonster() end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end