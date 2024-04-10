--青竜の忍者
--Blue Dragon Ninja
local s,id=GetID()
function s.initial_effect(c)
	--Negate the effects of an opponent's monster and make it unable to attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1)
	e1:SetCost(s.discost)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_NINJA,SET_NINJITSU_ART}
function s.discostfilter(c)
	return ((c:IsSetCard(SET_NINJA) and c:IsMonster()) or c:IsSetCard(SET_NINJITSU_ART)) and c:IsDiscardable()
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(function(c) return c:IsSetCard(SET_NINJA) and c:IsMonster() end,1,nil)
		and sg:IsExists(Card.IsSetCard,1,nil,SET_NINJITSU_ART)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local hg=Duel.GetMatchingGroup(s.discostfilter,tp,LOCATION_HAND,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(hg,e,tp,2,2,s.rescon,0) end
	local g=aux.SelectUnselectGroup(hg,e,tp,2,2,s.rescon,1,tp,HINTMSG_DISCARD)
	Duel.SendtoGrave(g,REASON_COST|REASON_DISCARD)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and not chkc:HasFlagEffect(id) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(aux.NOT(Card.HasFlagEffect),id),tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(aux.NOT(Card.HasFlagEffect),id),tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
		local c=e:GetHandler()
		if tc:IsFaceup() then
			--Negate its effects
			tc:NegateEffects(c,RESET_PHASE|PHASE_END)
		end
		--It cannot attack this turn
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3206)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end