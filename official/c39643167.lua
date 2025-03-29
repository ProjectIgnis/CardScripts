--ウサミミ導師
--Bunny Ear Enthusiast
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 Bunny Ears Counter to a monster on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.countercond)
	e1:SetTarget(s.countertg)
	e1:SetOperation(s.counterop)
	c:RegisterEffect(e1)
	--Banish itself and a monster with a Bunny Ears Counter
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e2:SetCountLimit(1)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.counter_place_list={0x1208}
function s.countercond(e,tp,eg,ep,ev,re,r,rp)
	return re:IsMonsterEffect() and re:GetActivateLocation()==LOCATION_MZONE and not re:GetHandler():IsCode(id)
end
function s.countertg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return re:GetHandler():IsRelateToEffect(re) and c:GetFlagEffect(id)==0 end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,tp,LOCATION_HAND)
end
function s.counterop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) and rc:IsFaceup() and rc:AddCounter(0x1208,1) then
		--Cannot be destroyed by battle
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetCondition(function(e) return e:GetHandler():GetCounter(0x1208)>0 end)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		rc:RegisterEffect(e1)
	end
end
function s.cfilter(c)
	return c:IsAbleToRemove() and c:GetCounter(0x1208)>0
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.cfilter(chkc) and chkc~=c end
	if chk==0 then return c:IsAbleToRemove() and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	g:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)) then return end
	local rg=Group.FromCards(c,tc)
	if #rg>0 then
		local turn_chk=Duel.GetTurnCount()
		local reset_count=Duel.GetCurrentPhase()<=PHASE_STANDBY and 2 or 1
		aux.RemoveUntil(rg,nil,REASON_EFFECT,PHASE_STANDBY,id+100,e,tp,aux.DefaultFieldReturnOp,
			function() return Duel.GetTurnCount()==turn_chk+1 end,
			RESET_PHASE|PHASE_STANDBY,reset_count
		)
	end
end