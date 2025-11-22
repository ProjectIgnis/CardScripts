--ドラグニティロード－ゲオルギアス
--Dragunity Lord - Georgius
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2+ monsters, including a Tuner
	Link.AddProcedure(c,nil,2,4,s.tunermatcheck)
	--Your opponent cannot activate the effects of monsters in the GY while this card is equipped with a "Dragunity" card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(function(e) return e:GetHandler():GetEquipGroup():IsExists(Card.IsSetCard,1,nil,SET_DRAGUNITY) end)
	e1:SetValue(function(e,re,tp) return re:IsMonsterEffect() and re:GetHandler():IsLocation(LOCATION_GRAVE) end)
	c:RegisterEffect(e1)
	--Special Summon 1 Level 5 or higher "Dragunity" monster from your Extra Deck or GY
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,0))
	e2a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY)
	e2a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2a:SetCountLimit(1,id)
	e2a:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e2a:SetTarget(s.sptg)
	e2a:SetOperation(s.spop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2b:SetRange(LOCATION_MZONE)
	e2b:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return not eg:IsContains(e:GetHandler()) and eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp) end)
	c:RegisterEffect(e2b)
	--Negate an opponent's activated Spell/Trap Card or effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==1-tp and re:IsSpellTrapEffect() and Duel.IsChainDisablable(ev) end)
	e3:SetCost(s.discost)
	e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return true end Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,tp,0) end)
	e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.NegateEffect(ev) end)
	c:RegisterEffect(e3)
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
end
s.listed_series={SET_DRAGUNITY}
function s.tunermatcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_TUNER,lc,sumtype,tp)
end
function s.spfilter(c,e,tp,mmz_chk)
	if not (c:IsLevelAbove(5) and c:IsSetCard(SET_DRAGUNITY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	else
		return mmz_chk
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,nil,e,tp,Duel.GetLocationCount(tp,LOCATION_MZONE)>0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,nil,e,tp,Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsEquipCard,Card.IsAbleToGraveAsCost),tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsEquipCard,Card.IsAbleToGraveAsCost),tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end