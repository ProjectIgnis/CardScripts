--幻影騎士団アンブレイジベイル
--The Phantom Knights of Umbrage Veil
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--If you have a "The Phantom Knights" monster in your field or GY, you can activate this card the turn it was Set
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e0:SetCondition(s.actcon)
	c:RegisterEffect(e0)
	--Special Summon this card in Defense Position as a Normal Monster (Warrior/DARK/Level 3/ATK 0/DEF 300) (this card is NOT treated as a Trap), then you can change 1 Attack Position monster your opponent controls to Defense Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--You can banish this card from your GY; immediately after this effect resolves, Xyz Summon 1 DARK Xyz Monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
s.listed_series={SET_THE_PHANTOM_KNIGHTS}
function s.actconfilter(c)
	return c:IsSetCard(SET_THE_PHANTOM_KNIGHTS) and c:IsMonster() and c:IsFaceup()
end
function s.actcon(e)
	return Duel.IsExistingMatchingCard(s.actconfilter,e:GetHandlerPlayer(),LOCATION_MZONE|LOCATION_GRAVE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:IsHasType(EFFECT_TYPE_ACTIVATE)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_THE_PHANTOM_KNIGHTS,TYPE_MONSTER|TYPE_NORMAL,0,300,3,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,nil,1,1-tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_THE_PHANTOM_KNIGHTS,TYPE_MONSTER|TYPE_NORMAL,0,300,3,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP_DEFENSE)
		c:AddMonsterAttributeComplete()
		if Duel.SpecialSummonComplete()>0 and Duel.IsExistingMatchingCard(aux.AND(Card.IsAttackPos,Card.IsCanChangePosition),tp,0,LOCATION_MZONE,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
			local posg=Duel.SelectMatchingCard(tp,aux.AND(Card.IsAttackPos,Card.IsCanChangePosition),tp,0,LOCATION_MZONE,1,1,nil)
			if #posg==0 then return end
			Duel.HintSelection(posg)
			Duel.BreakEffect()
			Duel.ChangePosition(posg,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE)
		end
	end
end
function s.xyzfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsXyzSummonable()
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	if sc then
		Duel.XyzSummon(tp,sc)
	end
end