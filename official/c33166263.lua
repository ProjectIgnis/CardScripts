--超越召喚獣アイオーン
--Invoked Transcendence Aeon
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 2+ Fusion Monsters with different Attributes
	Fusion.AddProcMixRep(c,true,true,s.matfilter,2,99)
	--If this card is Fusion Summoned: You can banish cards from the field and/or GYs, up to the number of materials used, then if you used 3 or more, you can look at your opponent's Extra Deck, and if you do, banish up to 3 cards from it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsFusionSummoned() end)
	e1:SetTarget(s.bantg)
	e1:SetOperation(s.banop)
	c:RegisterEffect(e1)
	--(Quick Effect): You can declare 1 Attribute; all other monsters currently on the field become that Attribute until the end of this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.attrtg)
	e2:SetOperation(s.attrop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e2)
end
function s.matfilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsType(TYPE_FUSION,fc,sumtype,tp) and
		(not sg or sg:FilterCount(aux.TRUE,c)==0 or not sg:IsExists(Card.IsAttribute,1,c,c:GetAttribute(fc,sumtype,tp),fc,sumtype,tp))
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
	local material_count=e:GetHandler():GetMaterialCount()
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,nil)
	if chk==0 then return material_count>0 and #g>0 end
	e:SetLabel(material_count)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,PLAYER_EITHER,LOCATION_ONFIELD|LOCATION_GRAVE)
	if material_count>=3 then
		Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,3,1-tp,LOCATION_EXTRA)
	end
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local material_count=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,1,material_count,nil)
	if #g==0 then return end
	Duel.HintSelection(g)
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and material_count>=3 then
		local extrag=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil)
		if #extrag>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.ConfirmCards(tp,extrag)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local sg=extrag:Select(tp,1,3,nil)
			if #sg>0 then
				Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
			end
			Duel.ShuffleExtra(1-tp)
		end
	end
end
function s.attrtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if chk==0 then return #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	e:SetLabel(Duel.AnnounceAnotherAttribute(g,tp))
end
function s.attrop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local exc=c:IsRelateToEffect(e) and c or nil
	local attr=e:GetLabel()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,exc)
	for tc in g:Iter() do
		--All other monsters currently on the field become that Attribute until the end of this turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(attr)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end