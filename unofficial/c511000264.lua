--極神聖帝オーディン (Anime)
--Odin, Father of the Aesir (Anime)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)
	--Synchro Summon procedure: 1 Tuner monster + 2 or more non-Tuner monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),2,99)
	--Until the End Phase of this turn, negate the effects of Spell/Trap Cards that would affect a Divine-Beast monster(s)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return not e:GetHandler():HasFlagEffect(511000263) end)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--Register for when this card is destroyed and sent to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	--Special Summon this card during the End Phase when it is destroyed and sent to the GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(93483212,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--If this card is Special Summoned by the above effect, draw 1 card
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(93483212,2))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1) end)
	e4:SetTarget(s.drtg)
	e4:SetOperation(s.drop)
	c:RegisterEffect(e4)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
		e1:SetCondition(s.imcon)
		e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.NegateEffect(ev) end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_PROC_G)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(s.discon)
		e1:SetOperation(s.disop)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(511000263,RESETS_STANDARD_PHASE_END,0,1)
	end
end
function s.cfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsRace(RACE_DIVINE)
end
function s.imcon(e,tp,eg,ep,ev,re,r,rp)
	if re:IsMonsterEffect() or not Duel.IsChainDisablable(ev) then return false end
	if re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		if g and g:IsExists(s.cfilter,1,nil) then return true end
	end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil)-#tg>0 then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_TOHAND)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil)-#tg>0 then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_REMOVE)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil)-#tg>0 then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_TODECK)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil)-#tg>0 then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_RELEASE)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil)-#tg>0 then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_TOGRAVE)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil)-#tg>0 then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_CONTROL)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil)-#tg>0 then
		return true
	end
	ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DISABLE)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil)-#tg>0 then
		return true
	end
	return false
end
function s.tgg(c,card)
	return c:GetCardTarget() and c:GetCardTarget():IsContains(card) and not c:IsDisabled()
end
function s.disfilter(c)
	local eqg=c:GetEquipGroup():Filter(aux.NOT(Card.IsDisabled),nil)
	local tgg=Duel.GetMatchingGroup(s.tgg,0,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,c)
	eqg:Merge(tgg)
	return c:IsRace(RACE_DIVINE) and #eqg>0
end
function s.discon(e,c,og)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp,c,og)
	Duel.Hint(HINT_CARD,0,id)
	local g=Duel.GetMatchingGroup(s.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local sg=Group.CreateGroup()
	local tc=g:GetFirst()
	while tc do
		local eqg=tc:GetEquipGroup():Filter(aux.NOT(Card.IsDisabled),nil)
		local tgg=Duel.GetMatchingGroup(s.tgg,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,tc)
		sg:Merge(eqg)
		sg:Merge(tgg)
		tc=g:GetNext()
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local dg=sg:Select(tp,1,99,nil)
	local dc=dg:GetFirst()
	while dc do
		Duel.NegateRelatedChain(dc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		dc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		dc:RegisterEffect(e2)
		if dc:IsType(TYPE_TRAPMONSTER) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESETS_STANDARD_PHASE_END)
			dc:RegisterEffect(e3)
		end
		dc=dg:GetNext()
	end
	Duel.BreakEffect()
	return
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local pos=c:GetPreviousPosition()
	if c:IsReason(REASON_BATTLE) then pos=c:GetBattlePosition() end
	if c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) and (pos&POS_FACEUP)>0 then
		c:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,1,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)
	end
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
