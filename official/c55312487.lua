--クルセイド・パラディオン
--Crusadia Vanguard
local s,id=GetID()
function s.initial_effect(c)
	--When you activate this card: You can also Tribute 1 "Crusadia" or "World Legacy" monster; if you did, Special Summon 1 "Crusadia" or "World Legacy" monster, with a different original name, from your Deck or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_BATTLE_START|TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--While you control a "Crusadia" Link Monster, your opponent's monsters can only target Link Monsters for attacks
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(function(e) return Duel.IsExistingMatchingCard(function(c) return c:IsSetCard(SET_CRUSADIA) and c:IsLinkMonster() end,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) end)
	e2:SetValue(function(e,c) return not c:IsLinkMonster() end)
	c:RegisterEffect(e2)
end
s.listed_series={SET_CRUSADIA,SET_WORLD_LEGACY}
function s.spcostfilter(c,e,tp)
	return c:IsSetCard({SET_CRUSADIA,SET_WORLD_LEGACY}) and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,c:GetOriginalCodeRule())
end
function s.spfilter(c,e,tp,code)
	return c:IsSetCard({SET_CRUSADIA,SET_WORLD_LEGACY}) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not c:IsOriginalCodeRule(code)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.CheckReleaseGroupCost(tp,s.spcostfilter,1,false,nil,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local sc=Duel.SelectReleaseGroupCost(tp,s.spcostfilter,1,1,false,nil,nil,e,tp):GetFirst()
		e:SetLabel(sc:GetOriginalCodeRule())
		Duel.Release(sc,REASON_COST)
	else
		e:SetLabel(-1)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:GetLabel()>0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	else
		e:SetCategory(0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local label=e:GetLabel()
	if label==-1 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp,label)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end