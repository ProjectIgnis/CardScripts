--星騎士 セイクリッド・カドケウス
--Tellarknight Constellar Caduceus
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure
	Xyz.AddProcedure(c,nil,4,2,nil,nil,99)
	--Add 1 "tellarknight" and/or 1 "Constellar" card from the GY to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Apply the effect of 1 "tellarknight" or "Constellar" monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.applycost)
	e2:SetTarget(s.applytg)
	e2:SetOperation(s.applyop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_TELLARKNIGHT,SET_CONSTELLAR}
function s.thfilter(c,e)
	return c:IsSetCard({SET_TELLARKNIGHT,SET_CONSTELLAR}) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg)
	return #sg==1 or (sg:IsExists(Card.IsSetCard,1,nil,SET_TELLARKNIGHT) and sg:IsExists(Card.IsSetCard,1,nil,SET_CONSTELLAR))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return #g>0 end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,1,tp,HINTMSG_ATOHAND)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,#tg,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
function s.rmvfilter(c,tp)
	if not (c:IsSetCard({SET_TELLARKNIGHT,SET_CONSTELLAR}) and c:IsAbleToRemoveAsCost()
		and c:IsHasEffect(id)) then 
		return false
	end
	local eff=c:GetCardEffect(id)
	local te=eff:GetLabelObject()
	local con=te:GetCondition()
	local tg=te:GetTarget()
	if (not con or con(te,tp,Group.CreateGroup(),PLAYER_NONE,0,eff,REASON_EFFECT,PLAYER_NONE,0)) 
		and (not tg or tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,eff,REASON_EFFECT,PLAYER_NONE,0)) then
		return true
	end
	return false
end
function s.applycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST)
		and Duel.IsExistingMatchingCard(s.rmvfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sc=Duel.SelectMatchingCard(tp,s.rmvfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	Duel.Remove(sc,POS_FACEUP,REASON_COST)
	sc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
	e:SetLabelObject(sc:GetCardEffect(id):GetLabelObject())
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local te=e:GetLabelObject()
	local tg=te and te:GetTarget() or nil
	if chkc then return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc) end
	if chk==0 then return true end
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	e:SetProperty(te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and EFFECT_FLAG_CARD_TARGET or 0)
	if tg then
		tg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	local sc=te:GetHandler()
	if sc:GetFlagEffect(id)==0 then
		e:SetLabel(0)
		e:SetLabelObject(nil)
		return
	end
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then
		op(e,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE)
	end
	e:SetLabel(0)
	e:SetLabelObject(nil)
end