--シューティング・ソニック
--Cosmic Flare
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMING_BATTLE_START)
	e1:SetCondition(function() return Duel.IsAbleToEnterBP() or (Duel.IsBattlePhase() and not Duel.IsPhase(PHASE_BATTLE)) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--If a "Stardust" Synchro Monster you control would Tribute itself to activate its effect, you can banish this card from your GY instead
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(84012625)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(function(e) return e:GetHandler():IsAbleToRemoveAsCost() end)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_STARDUST}
function s.tgfilter(c)
	return c:IsSetCard(SET_STARDUST) and c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
		--This turn, if that Synchro Monster you control battles an opponent's monster, shuffle that opponent's monster into the Deck at the start of the Damage Step
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_BATTLE_START)
		e1:SetCondition(s.tdcon)
		e1:SetOperation(s.tdop)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local bc1=Duel.GetBattleMonster(tp)
	if not bc1 then return false end
	local bc2=bc1:GetBattleTarget()
	return bc1 and bc1:IsType(TYPE_SYNCHRO) and bc1:IsFaceup() and bc1:HasFlagEffect(id)
		and bc2 and bc2:IsControler(1-tp)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local bc1=Duel.GetBattleMonster(tp)
	Duel.SendtoDeck(bc1:GetBattleTarget(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
function s.repval(base,e,tp,eg,ep,ev,re,r,rp,chk,extracon)
	local c=e:GetHandler()
	return c:IsSetCard(SET_STARDUST) and c:IsType(TYPE_SYNCHRO) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsFaceup() and (extracon==nil or extracon(base,e,tp,eg,ep,ev,re,r,rp))
end
function s.repop(base,e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Remove(base:GetHandler(),POS_FACEUP,REASON_COST|REASON_REPLACE)
end