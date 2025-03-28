--三戦の才
--Triple Tactics Talent
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
function s.chainfilter(re,tp,cid)
	return not (re:IsMonsterEffect() and Duel.IsMainPhase())
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)~=0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=s.drtg(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=s.cttg(e,tp,eg,ep,ev,re,r,rp,0)
	local b3=s.tdtg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)},
		{b3,aux.Stringid(id,2)})
	if op==1 then
		e:SetCategory(CATEGORY_DRAW)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e:SetOperation(s.drop)
		s.drtg(e,tp,eg,ep,ev,re,r,rp,1)
	elseif op==2 then
		e:SetCategory(CATEGORY_CONTROL)
		e:SetProperty(0)
		e:SetOperation(s.ctop)
		s.cttg(e,tp,eg,ep,ev,re,r,rp,1)
	elseif op==3 then
		e:SetCategory(CATEGORY_TODECK)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e:SetOperation(s.tdop)
		s.tdtg(e,tp,eg,ep,ev,re,r,rp,1)
	end
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE):Filter(Card.IsControlerCanBeChanged,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local tc=Duel.SelectMatchingCard(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc then
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,1-tp,LOCATION_HAND)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local g=Duel.GetFieldGroup(p,0,LOCATION_HAND)
	if #g>0 then
		Duel.ConfirmCards(p,g)
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
		local sg=g:Select(p,1,1,nil)
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		Duel.ShuffleHand(1-p)
	end
end