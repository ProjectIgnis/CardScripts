--No.49 秘鳥フォーチュンチュン
--Number 49: Fortune Tune
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 3 monsters
	Xyz.AddProcedure(c,nil,3,2)
	--Neither player can target this card on the field with card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--If this card would be destroyed by battle or card effect, you can detach 1 material from this card instead
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.reptg)
	c:RegisterEffect(e2)
	--Once per turn, during your Standby Phase: Gain 500 LP
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e3:SetTarget(s.rectg)
	e3:SetOperation(s.recop)
	c:RegisterEffect(e3)
	--If this card is sent from the field to the GY: Target 2 Level 3 monsters in your GY; shuffle them both into the Deck, and if you do, return this card from your GY to the Extra Deck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(function(e,tp) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
	e4:SetTarget(s.tdtg)
	e4:SetOperation(s.tdop)
	c:RegisterEffect(e4)
end
s.xyz_number=49
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	else return false end
end
function s.filter(c,e)
	return c:GetLevel()==3 and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,e) end
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e)
	if #g>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=g:Select(tp,2,2,nil)
		Duel.SetTargetCard(sg)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,2,tp,0)
	end
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if not g then return end
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)==2 then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end