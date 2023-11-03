--チェンジ・スライム－竜騎士形態
--Change Slime - Dragon Champion Mode
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	local params = {nil,nil,function(e,tp,mg) return nil,s.fcheck end}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e1:SetOperation(s.operation(Fusion.SummonEffOP(table.unpack(params))))
	c:RegisterEffect(e1)
end
function s.tdfilter(c)
	return c:IsMonster() and not c:IsType(TYPE_FUSION) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.fusfilter1(c)
	return c:IsLevel(7) and c:IsRace(RACE_WARRIOR)
end
function s.fusfilter2(c)
	return c:IsLevel(5) and c:IsRace(RACE_DRAGON)
end
function s.fcheck(tp,sg,fc)
	local mg1=sg:Filter(s.fusfilter1,nil)
	local mg2=sg:Filter(s.fusfilter2,nil)
	return #sg==2 and #mg1==1 and #mg2==1
end
function s.operation(oldop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local td=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if Duel.SendtoDeck(td,nil,SEQ_DECKSHUFFLE,REASON_COST)==0 then return end
		oldop(e,tp,eg,ep,ev,re,r,rp)
	end
end