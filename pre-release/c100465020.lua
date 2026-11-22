--ラメイソンの守り手ジュノン
--Protector of the Grand Tower
--Scripted by aht
local s,id=GetID()
function s.initial_effect(c)
	--If this card is in your hand and you have 3 or more Spells with different names in your GY: You can Special Summon this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetMatchingGroup(Card.IsSpell,tp,LOCATION_GRAVE,0,nil):GetClassCount(Card.GetCode)>=3
	end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--You can target 1 "Spellbook" card and 1 Spell in your GY; banish 1 of them, and if you do, add the other to your hand, then if it is a "Spellbook" card, you can destroy 1 card on the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.rmthtg)
	e2:SetOperation(s.rmthop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SPELLBOOK}
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.rmthfilter(c,e)
	return (c:IsSetCard(SET_SPELLBOOK) or c:IsSpell()) and (c:IsAbleToRemove() or c:IsAbleToHand())
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsSetCard,1,nil,SET_SPELLBOOK)
		and sg:IsExists(Card.IsSpell,1,nil)
		and sg:IsExists(Card.IsAbleToRemove,1,nil)
		and sg:IsExists(Card.IsAbleToHand,1,nil)
end
function s.rmthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetTargetGroup(s.rmthfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tg,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_EITHER,LOCATION_ONFIELD)
end
function s.rmfilter(c,g)
	return c:IsAbleToRemove() and g:IsExists(Card.IsAbleToHand,1,c)
end
function s.rmthop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=tg:FilterSelect(tp,s.rmfilter,1,1,nil,tg)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		local addc=tg:Sub(g):GetFirst()
		if addc and Duel.SendtoHand(addc,nil,REASON_EFFECT)>0 and addc:IsSetCard(SET_SPELLBOOK)
			and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)>0
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local desg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			if #desg==0 then return end
			Duel.HintSelection(desg)
			Duel.BreakEffect()
			Duel.Destroy(desg,REASON_EFFECT)
		end
	end
end