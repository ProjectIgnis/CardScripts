--ウィジャ盤
--Destiny Board
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--place card
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOFIELD)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetLabel(id)
	e2:SetCondition(s.plcon)
	e2:SetTarget(s.pltg)
	e2:SetOperation(s.plop)
	e2:SetValue(s.extraop)
	c:RegisterEffect(e2)
	--tograve
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(s.tgcon)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
	--win
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_ADJUST)
	e5:SetRange(LOCATION_SZONE)
	e5:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetOperation(s.winop)
	c:RegisterEffect(e5)
end
s.listed_names={id}
s.listed_series={0x1c}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.GetCurrentPhase()==PHASE_END and s.plcon(e,tp,eg,ep,ev,re,r,rp) and Duel.SelectYesNo(tp,94) then
		e:SetCategory(CATEGORY_TOFIELD)
		e:SetLabel(id)
		e:SetOperation(s.plop)
		e:SetValue(s.extraop)
		e:GetHandler():RegisterFlagEffect(0,RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,65)
		e:GetHandler():RegisterFlagEffect(id+1,RESET_PHASE+PHASE_END,0,1)
	else
		e:SetLabel(0)
		e:SetOperation(nil)
	end
end
function s.plcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and e:GetHandler():GetFlagEffect(id)<4
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(id+1)==0 end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_DARK_SANCTUARY) then return s.extraop(e,tp,eg,ep,ev,re,r,rp) end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local passcode=CARDS_SPIRIT_MESSAGE[c:GetFlagEffect(id)+1]
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,passcode)
	if #g>0 and Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
	end
end
function s.extraop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local cid=CARDS_SPIRIT_MESSAGE[c:GetFlagEffect(id)+1]
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,cid)
	local tc=g:GetFirst()
	if tc and Duel.IsPlayerCanSpecialSummonMonster(tp,cid,0,0x11,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP,tp,181)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (Duel.GetLocationCount(tp,LOCATION_SZONE)<1 or Duel.SelectYesNo(tp,aux.Stringid(CARD_DARK_SANCTUARY,0))) then
		tc:AddMonsterAttribute(TYPE_NORMAL,ATTRIBUTE_DARK,RACE_FIEND,1,0,0)
		Duel.SpecialSummonStep(tc,181,tp,tp,true,false,POS_FACEUP)
		tc:AddMonsterAttributeComplete()
		--immune
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_EVENT+0x47c0000)
		tc:RegisterEffect(e1)
		--cannot be target
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
		e2:SetReset(RESET_EVENT+0x47c0000)
		tc:RegisterEffect(e2)
		Duel.SpecialSummonComplete()
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
	elseif tc and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
	end
end
function s.efilter(e,te)
	local tc=te:GetHandler()
	return not tc:IsCode(id)
end
function s.cfilter1(c,tp)
	return c:IsControler(tp) and (c:IsCode(id) or c:IsSetCard(0x1c))
end
function s.cfilter2(c)
	return c:IsFaceup() and (c:IsCode(id) or c:IsSetCard(0x1c))
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter1,1,nil,tp)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter2,tp,LOCATION_ONFIELD,0,nil)
	Duel.SendtoGrave(g,REASON_EFFECT)
end
function s.cfilter3(c)
	return c:IsFaceup() and c:IsCode(table.unpack(CARDS_SPIRIT_MESSAGE))
end
function s.winop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter3,tp,LOCATION_ONFIELD,0,e:GetHandler())
	if g:GetClassCount(Card.GetCode)==4 then
		Duel.Win(tp,WIN_REASON_DESTINY_BOARD)
	end
end
