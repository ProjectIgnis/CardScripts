--ビンゴカード
--Bingo Card
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Choose 1 monster in a column with all zones occupied and destroy as many cards in that column as possible, then each player draws 1 card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--You can banish this card from your GY, then activate 1 of these effects;
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
function s.columnfilter(c)
	return c:GetColumnGroupCount()==(c:IsSequence(0,2,4) and 3 or 4)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.columnfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,4,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sc=Duel.SelectMatchingCard(tp,s.columnfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	if not sc then return end
	Duel.HintSelection(sc)
	local c=e:GetHandler()
	local g=sc:GetColumnGroup():AddCard(sc)
	if c:IsRelateToEffect(e) then g:RemoveCard(c) end
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		local turn_player=Duel.GetTurnPlayer()
		Duel.BreakEffect()
		Duel.Draw(turn_player,1,REASON_EFFECT)
		Duel.Draw(1-turn_player,1,REASON_EFFECT)
	end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	--● Destroy 5 monsters in your Main Monster Zone or 5 cards in your Spell & Trap Zone, then draw 2 cards
	local own_mmzone=Duel.GetFieldGroup(tp,LOCATION_MMZONE,0)
	local own_stzone=Duel.GetFieldGroup(tp,LOCATION_STZONE,0)
	local b1=(#own_mmzone==5 or #own_stzone==5) and Duel.IsPlayerCanDraw(tp,2)
	--● Destroy 5 monsters in your opponent's Main Monster Zone or 5 cards in their Spell & Trap Zone, then they draw 2 cards
	local opp=1-tp
	local opp_mmzone=Duel.GetFieldGroup(opp,LOCATION_MMZONE,0)
	local opp_stzone=Duel.GetFieldGroup(opp,LOCATION_STZONE,0)
	local b2=(#opp_mmzone==5 or #opp_stzone==5) and Duel.IsPlayerCanDraw(opp,2)
	if chk==0 then return b1 or b2 end
	local cd=e:GetChainData()
	cd.choice=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	if cd.choice==1 then
		--● Destroy 5 monsters in your Main Monster Zone or 5 cards in your Spell & Trap Zone, then draw 2 cards
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,own_mmzone+own_stzone,5,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	else
		--● Destroy 5 monsters in your opponent's Main Monster Zone or 5 cards in their Spell & Trap Zone, then they draw 2 cards
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,opp_mmzone+opp_stzone,5,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,opp,2)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local player=e:GetChainData().choice==1 and tp or 1-tp
	local mmzone=Duel.GetFieldGroup(player,LOCATION_MMZONE,0)
	local stzone=Duel.GetFieldGroup(player,LOCATION_STZONE,0)
	local op=nil
	local b1=#mmzone==5
	local b2=#stzone==5
	if b1 and b2 then
		op=Duel.SelectEffect(tp,
			{true,aux.Stringid(id,4)},
			{true,aux.Stringid(id,5)})
	else
		op=(b1 and 1) or (b2 and 2) or nil
	end
	if op and Duel.Destroy(op==1 and mmzone or stzone,REASON_EFFECT)==5
		and Duel.IsPlayerCanDraw(player) then
		Duel.BreakEffect()
		Duel.Draw(player,2,REASON_EFFECT)
	end
end