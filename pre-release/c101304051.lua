--神書の使いラハムゥ
--Lahamu the Messenger of Sacred Scripture
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2 Effect Monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2)
	--Once while this Link Summoned card is face-up on the field, you can Normal Summon 1 Level 5 or higher monster without Tributing
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.ntcon)
	e1:SetTarget(aux.FieldSummonProcTg(function(e,c) return c:IsLevelAbove(5) end))
	c:RegisterEffect(e1)
	--During the Main Phase, you can (Quick Effect): Immediately after this effect resolves, Normal Summon 1 Level 5 or higher DARK monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function() return Duel.IsMainPhase() end)
	e2:SetTarget(s.nstg)
	e2:SetOperation(s.nsop)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e2)
	--During your End Phase: You can reveal any number of monsters in your hand and place them on the bottom of the Deck in any order, then draw the same number of cards
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return e:GetHandler():IsLinkSummoned() and minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.nsfilter(c)
	return c:IsSummonable(true,nil) and c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
	if sc then
		Duel.Summon(tp,sc,true,nil)
	end
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsMonster,Card.IsAbleToDeck),tp,LOCATION_HAND,0,1,nil)
		and Duel.IsPlayerCanDraw(tp) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local target_player=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local max_count=Duel.GetMatchingGroupCount(aux.AND(Card.IsMonster,Card.IsAbleToDeck),target_player,LOCATION_HAND,0,nil)
	if max_count==0 then return end
	Duel.Hint(HINT_SELECTMSG,target_player,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(target_player,aux.AND(Card.IsMonster,Card.IsAbleToDeck),target_player,LOCATION_HAND,0,1,max_count,nil)
	if #g>0 then
		Duel.ConfirmCards(1-target_player,g)
		local draw_count=Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		if draw_count>0 then
			if draw_count>1 then Duel.SortDeckbottom(target_player,target_player,draw_count) end
			Duel.BreakEffect()
			Duel.Draw(target_player,draw_count,REASON_EFFECT)
		end
	end
end