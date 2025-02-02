--デーモンの供物
--Offering to the Archfiend
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Make 1 of opponent's monsters able to be Tributed
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
end
function s.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(8) and c:IsNotMaximumModeSide() and not c:IsHasEffect(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.HintSelection(g)
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	local g2=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK)
	if #g2>1 then
		Duel.SortDeckbottom(tp,tp,#g2)
	end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g==0 then return end
	local tc=g:GetFirst()
	Duel.HintSelection(g)
	--Tribute monster to summon Summoned Skull
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(id)
	e1:SetValue(2)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetCondition(s.otcon1)
	e2:SetTarget(aux.FieldSummonProcTg(s.ottg1,s.sumtg1))
	e2:SetOperation(s.otop)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SUMMON_PROC)
	e3:SetTargetRange(LOCATION_HAND,0)
	e3:SetCondition(s.otcon2)
	e3:SetTarget(aux.FieldSummonProcTg(s.ottg2,s.sumtg2))
	e3:SetOperation(s.otop)
	e3:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e3,tp)
end
function s.tgfilter1(c,e)
	return c:IsReleasable(REASON_SUMMON) and c:IsNotMaximumModeSide()
end
function s.tgfilter2(c,e)
	return c:IsReleasable(REASON_SUMMON) and c:IsNotMaximumModeSide() and c:IsHasEffect(id)
end
function s.tgfilter(c,e,tp)
	if c:IsControler(tp) then return s.tgfilter1(c,e) end
	return s.tgfilter2(c,e)
end
function s.otcon1(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.tgfilter2,tp,0,LOCATION_MZONE,1,nil,e)
end
function s.ottg1(e,c)
	return c:IsCode(CARD_SUMMONED_SKULL) and c:IsLevel(5,6)
end
function s.sumtg1(e,tp,eg,ep,ev,re,r,rp,c)
	local oppg=Duel.GetMatchingGroup(s.tgfilter2,tp,0,LOCATION_MZONE,nil,e)
	local g1=oppg:Select(tp,1,1,true,nil)
	if not g1 then return false end
	g1:KeepAlive()
	e:SetLabelObject(g1)
	return true
end
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	if not sg then return end
	c:SetMaterial(sg)
	Duel.Release(sg,REASON_SUMMON)
	sg:DeleteGroup()
end
function s.otcon2(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil,e,tp)
end
function s.ottg2(e,c)
	return c:IsCode(CARD_SUMMONED_SKULL) and c:IsLevelAbove(7)
end
function s.sumtg2(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp)
	local g1=aux.SelectUnselectGroup(sg,1,tp,2,2,aux.ChkfMMZ(1),1,tp,HINTMSG_RELEASE,nil,nil,true)
	if #g1<2 then return false end
	g1:KeepAlive()
	e:SetLabelObject(g1)
	return true
end