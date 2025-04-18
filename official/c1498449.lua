--星辰砲手ファイメナ
--Dragontail Fymena
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon 1 Dragon or Spellcaster Fusion Monster from your Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetCost(Cost.SelfDiscard)
	e1:SetTarget(s.fustg)
	e1:SetOperation(Fusion.SummonEffOP({fusfilter=aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON|RACE_SPELLCASTER)}))
	c:RegisterEffect(e1)
	--Set 1 "Dragontail" Spell/Trap from your Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsLocation(LOCATION_GRAVE) and (r&REASON_FUSION)==REASON_FUSION end)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_DRAGONTAIL}
function s.fextra(exc)
	return function(e,tp,mg)
		return nil,s.fcheck(exc)
	end
end
function s.fcheck(exc)
	return function(tp,sg,fc)
		return not (exc and sg:IsContains(exc))
	end
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local params={extrafil=s.fextra(e:GetHandler()),fusfilter=aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON|RACE_SPELLCASTER)}
		return Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
	end
	Fusion.SummonEffTG({fusfilter=aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON|RACE_SPELLCASTER)})(e,tp,eg,ep,ev,re,r,rp,1)
end
function s.setfilter(c)
	return c:IsSetCard(SET_DRAGONTAIL) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end