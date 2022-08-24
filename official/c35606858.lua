--パーペチュアルキングデーモン
--Masterking Archfiend
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FIEND),2,2)
	--Maintenance cost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(_,tp) return Duel.IsTurnPlayer(tp) end)
	e1:SetOperation(s.mtop)
	c:RegisterEffect(e1)
	--Send 1 Fiend from your Deck to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_PAY_LPCOST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(_,tp,_,ep) return ep==tp end)
	e2:SetLabel(0)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	--Roll a die and apply the appropriate result
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DICE+CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetLabel(1)
	e3:SetTarget(s.dctg)
	e3:SetOperation(s.dcop)
	c:RegisterEffect(e3)
end
s.roll_dice=true
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CheckLPCost(tp,500) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.PayLPCost(tp,500)
	else
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
function s.once_per_chain_chk(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local label=e:GetLabel()
	if chk==0 then return c:GetFlagEffect(id+label)==0 and not c:IsStatus(STATUS_CHAINING) end
	c:RegisterFlagEffect(id+label,RESET_CHAIN,0,1)
end
function s.tgfilter(c,val)
	return c:IsRace(RACE_FIEND) and c:IsMonster() and (c:IsAttack(val) or c:IsDefense(val)) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,ev) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,ev)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function s.cfilter(c,e,tp,ft)
	return c:IsRace(RACE_FIEND) and c:IsControler(tp) and (c:IsAbleToHand() or c:IsAbleToDeck()
		or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.dctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return eg:IsExists(s.cfilter,1,nil,e,tp,ft) end
	local g=eg:Filter(s.cfilter,nil,e,tp,ft)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.dcop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end
	local d=Duel.TossDice(tp,1)
	local tc=nil
	if d==1 then
		tc=s.mon_select(g,tp,Card.IsAbleToHand,HINTMSG_ATOHAND)
		if not tc then return end
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	elseif d==6 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
		tc=s.mon_select(g,tp,Card.IsCanBeSpecialSummoned,HINTMSG_SPSUMMON,e,0,tp,false,false)
		if not tc then return end
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	elseif d>1 and d<6 then
		tc=s.mon_select(g,tp,Card.IsAbleToDeck,HINTMSG_TODECK)
		if not tc then return end
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function s.mon_select(g,tp,func,hint,...)
	local tc=nil
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,hint)
		tc=g:FilterSelect(tp,func,1,1,nil,...):GetFirst()
	else
		tc=g:GetFirst()
		if not func(tc,...) then tc=nil end
	end
	if tc then Duel.HintSelection(tc,true) end
	return tc
end
