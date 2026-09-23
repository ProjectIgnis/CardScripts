--レイズ・ムーンの翼 ラピ
--Raise Moon Wings Rapi
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--When you draw this card: You can reveal it; Special Summon it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DRAW)
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end)
	c:RegisterEffect(e1)
	--If this card is Normal or Special Summoned from the hand: You can draw 1 card, also you cannot Special Summon from the Extra Deck for the rest of this turn, except LIGHT Xyz Monsters. You cannot add cards from the Deck to the hand the turn you activate this effect, except by drawing them
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_DRAW)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY)
	e2a:SetCode(EVENT_SUMMON_SUCCESS)
	e2a:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsSummonLocation(LOCATION_HAND)
	end)
	e2a:SetCost(s.drcost)
	e2a:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end)
	e2a:SetOperation(s.drop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
	--Keep track of cards being added to a player's hand, except by drawing them
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_HAND)
		ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			for ec in eg:Iter() do
				if ec:IsPreviousLocation(LOCATION_DECK) and not ec:IsReason(REASON_DRAW) then
					Duel.RegisterFlagEffect(ec:GetReasonPlayer(),id,RESET_PHASE|PHASE_END,0,1)
				end
			end
		end)
		Duel.RegisterEffect(ge1,0)
	end)
	--Once per opponent's turn, you can (Quick Effect): Immediately after this effect resolves, Xyz Summon 1 Rank 7 LIGHT monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsTurnPlayer(1-tp)
	end)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	e3:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e3)
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) end
	--You cannot add cards from the Deck to the hand the turn you activate this effect, except by drawing them
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,tp,re)
		return c:IsLocation(LOCATION_DECK)
	end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
	--You cannot Special Summon from the Extra Deck for the rest of this turn, except LIGHT Xyz Monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c)
		return c:IsLocation(LOCATION_EXTRA) and not (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsXyzMonster())
	end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.xyzfilter(c)
	return c:IsRank(7) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsXyzSummonable()
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