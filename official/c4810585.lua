--戦華史略－長坂之雄
--Ancient Warriors Saga - Defense of Changban
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMING_BATTLE_START)
	c:RegisterEffect(e0)
	--If your "Ancient Warriors" monster battles, your opponent cannot activate Spells/Traps until the end of the Damage Step
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(s.cannotactcon)
	e1:SetValue(function(e,re,tp) return re:IsHasType(EFFECT_TYPE_ACTIVATE) end)
	c:RegisterEffect(e1)
	--Make monsters your opponent controls unable to target "Ancient Warriors" monsters for attacks this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMING_BATTLE_START)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) and Duel.IsPhase(PHASE_BATTLE_START) and not Duel.HasFlagEffect(tp,id) end)
	e2:SetCost(s.cannotatkcost)
	e2:SetOperation(s.cannotatkop)
	c:RegisterEffect(e2)
	--Special Summon 1 "Ancient Warriors" monster from your Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(e,tp) return Duel.GetAttacker():IsControler(1-tp) end)
	e3:SetCost(Cost.SelfBanish)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ANCIENT_WARRIORS}
function s.cannotactcon(e)
	local bc=Duel.GetBattleMonster(e:GetHandlerPlayer())
	return bc and bc:IsSetCard(SET_ANCIENT_WARRIORS) and bc:IsFaceup()
end
function s.cannotatkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED) end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.cannotatkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.HasFlagEffect(tp,id) then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	local c=e:GetHandler()
	--Monsters your opponent controls cannot target "Ancient Warriors" monsters for attacks this turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(function(e,c) return c:IsSetCard(SET_ANCIENT_WARRIORS) and c:IsFaceup() end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Auxiliary.RegisterClientHint(c,nil,tp,0,1,aux.Stringid(id,2))
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ANCIENT_WARRIORS) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end