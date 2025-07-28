--ＳＰＹＧＡＬ－ミスティ
--SPYGAL Misty
local s,id=GetID()
function s.initial_effect(c)
	--Reveal the top card of your opponent's Deck, and if you do, draw 1 card if it is a card of the declared type
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_DRAW)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetTarget(s.drtg)
	e1a:SetOperation(s.drop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--Return 1 "SPYRAL Super Agent" you control and 1 monster your opponent controls to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.rthtg)
	e2:SetOperation(s.rthop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_SPYRAL_SUPER_AGENT}
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	e:SetLabel(Duel.SelectOption(tp,DECLTYPE_MONSTER,DECLTYPE_SPELL,DECLTYPE_TRAP))
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
	local opt=e:GetLabel()
	Duel.ConfirmDecktop(1-tp,1)
	local top_c=Duel.GetDecktopGroup(1-tp,1):GetFirst()
	if (opt==0 and top_c:IsMonster()) or (opt==1 and top_c:IsSpell()) or (opt==2 and top_c:IsTrap()) then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
function s.rthfilter(c,e,tp)
	return ((c:IsCode(CARD_SPYRAL_SUPER_AGENT) and c:IsFaceup()) or c:IsControler(1-tp)) and c:IsAbleToHand()
		and c:IsCanBeEffectTarget(e)
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.rthfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetControler),0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetControler),1,tp,HINTMSG_RTOHAND)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,2,tp,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==2 and tg:FilterCount(Card.IsMonster,nil)==2 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end