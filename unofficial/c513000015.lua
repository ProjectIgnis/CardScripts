--ＴＧ ブレード・ガンナー MAXX-10000
--T.G. Blade Blaster (Anime)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner Synchro Monster + 1+ non-Tuner Synchro Monsters
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_SYNCHRO),1,1,Synchro.NonTunerEx(Card.IsType,TYPE_SYNCHRO),1,99)
	--You can Synchro Summon this card during your opponent's turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) and not e:GetHandler():IsStatus(STATUS_CHAINING) end)
	e1:SetTarget(s.syntg)
	e1:SetOperation(s.synop)
	c:RegisterEffect(e1)
	--Negate the effect of your opponent's Spell/Trap Card that would affect this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return true end Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,tp,0) end)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.NegateEffect(ev) end)
	c:RegisterEffect(e2)
	--Banish this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e3:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	--Return this card to the field
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_REMOVED)
	e4:SetCountLimit(1)
	e4:SetCondition(function(e,tp) return e:GetHandler():HasFlagEffect(id) and Duel.IsTurnPlayer(1-tp) end)
	e4:SetOperation(function(e) local c=e:GetHandler() if c:IsRelateToEffect(e) then Duel.ReturnToField(c) end end)
	c:RegisterEffect(e4)
	--Special Summon all of the monsters that were used for the Synchro Summon of this card from your GY
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,4))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BATTLE_DESTROYED)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end
s.synchro_tuner_required=1
s.synchro_nt_required=1
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSynchroSummonable() end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SynchroSummon(tp,c)
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==1-tp and re:IsSpellTrapEffect() and Duel.IsChainDisablable(ev)) then return false end
	local ex,g=nil
	local c=e:GetHandler()
	local eff_categories={CATEGORY_DESTROY,CATEGORY_RELEASE,CATEGORY_REMOVE,CATEGORY_TOHAND,CATEGORY_TODECK,
		CATEGORY_TOGRAVE,CATEGORY_POSITION,CATEGORY_CONTROL,CATEGORY_DISABLE,CATEGORY_EQUIP,
		CATEGORY_ATKCHANGE,CATEGORY_DEFCHANGE,CATEGORY_LVCHANGE,CATEGORY_NEGATE,CATEGORY_TOEXTRA}
	for _,category in ipairs(eff_categories) do
		ex,g=Duel.GetOperationInfo(ev,category)
		if ex and g and ((type(g)=="Card" and g==c) or (type(g)=="Group" and g:IsContains(c))) then
			return true
		end
	end
	return false
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,tp,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT|REASON_TEMPORARY)>0
		and c:IsLocation(LOCATION_REMOVED) then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,0)
	end
end
function s.spfilter(c,e,tp,sync)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and (c:GetReason()&(REASON_SYNCHRO|REASON_MATERIAL))==(REASON_SYNCHRO|REASON_MATERIAL)
		and sync:IsReasonCard(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	local ct=#mg
	if chk==0 then return c:IsSynchroSummoned() and ct>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct
		and mg:FilterCount(s.spfilter,nil,e,tp,c)==ct
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,mg,ct,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local mg=c:GetMaterial()
	local ct=#mg
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct
		and mg:FilterCount(aux.NecroValleyFilter(s.spfilter),nil,e,tp,c)==ct then
		Duel.SpecialSummon(mg,0,tp,tp,false,false,POS_FACEUP)
	end
end