--動点するＰ
--Moving Point Pendulum
--scripted by pyrQ
local s,id=GetID()
local COUNTER_T=0x218
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_T)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Once per turn, during the Standby Phase: Place 1 T Counter on this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetOperation(function(e) e:GetHandler():AddCounter(COUNTER_T,1) end)
	c:RegisterEffect(e1)
	--Once per turn: You can target 1 Pendulum Monster in your Main Monster Zone; move that Pendulum Monster to an unused adjacent Main Monster Zone a number of times equal to the number of T Counters on this card, then if your opponent controls in the targeted monster's column a Fusion and/or Xyz Monster(s) with a Level/Rank equal to or lower than the targeted monster's Pendulum Scale, destroy as many of them as possible, and if you do, inflict damage to your opponent equal to the total ATK the destroyed monsters had on the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e) return e:GetHandler():HasCounter(COUNTER_T) end)
	e2:SetTarget(s.movetg)
	e2:SetOperation(s.moveop)
	e2:SetHintTiming(TIMING_STANDBY_PHASE,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
function s.movefilter(c)
	return c:IsPendulumMonster() and c:IsFaceup() and c:CheckAdjacent()
end
function s.movetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.movefilter,tp,LOCATION_MMZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.movefilter,tp,LOCATION_MMZONE,0,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.desfilter(c,opp,scale)
	if not ((c:IsFusionMonster() or c:IsXyzMonster()) and c:IsFaceup() and c:IsControler(opp)) then return false end
	if c:HasLevel() then
		return c:IsLevelBelow(scale)
	elseif c:HasRank() then
		return c:IsRankBelow(scale)
	end
end
function s.moveop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:HasCounter(COUNTER_T)) then return end
	local tc=Duel.GetFirstTarget()
	local move_count=c:GetCounter(COUNTER_T)
	if tc:IsRelateToEffect(e) and tc:IsPendulumMonster() and tc:IsFaceup() then
		for i=1,move_count do
			tc:MoveAdjacent()
		end
	end
	local opp=1-tp
	local column_g=tc:GetColumnGroup():Match(s.desfilter,nil,opp,tc:GetScale())
	if #column_g==0 then return end
	Duel.BreakEffect()
	if Duel.Destroy(column_g,REASON_EFFECT)==0 then return end
	local total_atk=Duel.GetOperatedGroup():GetSum(Card.GetPreviousAttackOnField)
	if total_atk>0 then
		Duel.Damage(opp,total_atk,REASON_EFFECT)
	end
end