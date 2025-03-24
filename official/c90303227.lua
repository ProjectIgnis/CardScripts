--Ｋ９－ＥＸ “Ｗｅｒｅｗｏｌｆ”
--K9 - EX "Werewolf"
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 9 monsters
	Xyz.AddProcedure(c,nil,9,2)
	--Can attack a number of times each Battle Phase, up to the number of materials attached to it
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(function(e,c) return math.max(0,e:GetHandler():GetOverlayCount()-1) end)
	c:RegisterEffect(e1)
	--Activate this effect depending on whose turn it is
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp end)
	e2:SetCost(Cost.Detach(1))
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=Duel.IsTurnPlayer(tp) and LOCATION_ONFIELD|LOCATION_GRAVE or LOCATION_HAND
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,loc,1,nil) end
	e:SetLabel(loc)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,loc)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local loc=e:GetLabel()
	local g=Duel.GetFieldGroup(tp,0,loc)
	if #g==0 then return end
	if loc==LOCATION_HAND then
		Duel.ConfirmCards(tp,g)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local tc=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
		if tc then
			aux.RemoveUntil(tc,POS_FACEUP,REASON_EFFECT|REASON_TEMPORARY,PHASE_END,id,e,tp,function(rg,e,tp) Duel.SendtoHand(tc,nil,REASON_EFFECT) end)
		end
		Duel.ShuffleHand(1-tp)
	else
		local rg=aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,1,tp,HINTMSG_REMOVE)
		if #rg==0 then return end
		Duel.HintSelection(rg)
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_ONFIELD)<=1
		and sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=1
end