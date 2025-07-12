--死祖の隷竜ウォロー
--Wollow, Founder of the Drudge Dragons
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2+ Level 6 monsters
	Xyz.AddProcedure(c,nil,6,2,nil,nil,Xyz.InfiniteMats)
	--Monsters you control gain 100 ATK/DEF for each card in your opponent's GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(function(e) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_GRAVE)*100 end)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Activate the appropriate effect based on the number of detached materials
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1,id)
	e3:SetCost(Cost.AND(s.efftgcost,s.effdetachcost))
	e3:SetTarget(s.efftg)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
end
function s.tgfilter(c,e,tp,detach_1,detach_2)
	return (detach_1 and c:IsAbleToDeck()) or (detach_2 and s.setfilter(c,e,tp))
end
function s.setfilter(c,e,tp)
	if c:IsSpellTrap() then return c:IsSSetable() end
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP|POS_FACEDOWN_DEFENSE)
end
function s.efftgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local detach_1=c:CheckRemoveOverlayCard(tp,1,REASON_COST)
	local detach_2=c:CheckRemoveOverlayCard(tp,2,REASON_COST)
	if chk==0 then return (detach_1 or detach_2)
		and Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp,detach_1,detach_2) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,detach_1,detach_2)
end
function s.tccheck(op)
	return function(e,tp)
		local tc=Duel.GetFirstTarget()
		if not tc then return true end
		return op==1 and tc:IsAbleToDeck() or s.setfilter(tc,e,tp)
	end
end
s.effdetachcost=Cost.Choice(
	{Cost.DetachFromSelf(1),aux.Stringid(id,1),s.tccheck(1)},
	{Cost.DetachFromSelf(2),aux.Stringid(id,2),s.tccheck(2)}
)
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return true end
	local op=e:GetLabel()
	local categ=CATEGORY_TODECK
	local tc=Duel.GetFirstTarget()
	if op==2 then categ=tc:IsMonster() and CATEGORY_SPECIAL_SUMMON or CATEGORY_LEAVE_GRAVE end
	e:SetCategory(categ)
	Duel.SetOperationInfo(0,categ,tc,1,tp,0)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local op=e:GetLabel()
	if op==1 then
		--Return it to the Deck
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	elseif op==2 then
		--If the target is a monster, Special Summon it face-up, or in face-down Defense Position, to your field
		if tc:IsMonster() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP|POS_FACEDOWN_DEFENSE)>0
			and tc:IsFacedown() then
			Duel.ConfirmCards(1-tp,tc)
		--If it is not, Set it on your field
		elseif tc:IsSSetable() then
			Duel.SSet(tp,tc)
		end
	end
end
