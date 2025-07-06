--サイキッカー・オラクル
--Axon Kicker Oracle
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 Psychic monster + 1 Synchro, Xyz, or Link Monster
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_PSYCHIC),aux.FilterBoolFunctionEx(Card.IsType,TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK))
	--After this card is Fusion Summoned, it gains 1000 ATK for each Synchro, Xyz, and Link Monster used as it material until the end of the next turn
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(function(e,c) e:SetLabel(c:GetMaterial():FilterCount(Card.IsType,nil,TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)) end)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsFusionSummoned() end)
	e1:SetOperation(function(e) e:GetHandler():UpdateAttack(e0:GetLabel()*1000,RESETS_STANDARD_DISABLE_PHASE_END,nil,2) end)
	c:RegisterEffect(e1)
	--Negate an opponent's Special Summon and banish that monster(s)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp,eg,ep) return ep==1-tp and Duel.GetCurrentChain()==0 end)
	e2:SetTarget(s.negsumtg)
	e2:SetOperation(s.negsumop)
	c:RegisterEffect(e2)
	--Special Summon this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(e) local c=e:GetHandler() return c:IsFusionSummoned() and c:IsPreviousLocation(LOCATION_MZONE) end)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.miracle_synchro_fusion=true
s.listed_series={SET_TELEPORT}
function s.negsumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(Card.IsAbleToRemove,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,#eg,tp,0)
end
function s.negsumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
end
function s.spcostfilter(c)
	return c:IsSetCard(SET_TELEPORT) and (c:IsNormalSpell() or c:IsQuickPlaySpell()) and c:IsAbleToRemoveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end