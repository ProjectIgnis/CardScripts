--JP name
--Fleeting Flower of the Magician
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 Spell/Trap on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_LEAVE_GRAVE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
function s.desfilter(c,tp)
	return c:IsSpellTrap() and (c:IsFaceup() or c:IsControler(tp))
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc~=c and chkc:IsOnField() and s.desfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tc=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c,tp):GetFirst()
	e:SetLabel(tc:IsControler(tp) and 106 or 0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.plfilter(c,tp)
	return c:IsMonster() and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.thfilter(c)
	return (c:IsEquipSpell() or c:IsContinuousSpell()) and c:IsAbleToHand()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or Duel.Destroy(tc,REASON_EFFECT)==0 or e:GetLabel()~=106 then return end
	local plg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.plfilter),tp,LOCATION_GRAVE,0,nil,tp)
	local thg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,nil)
	local b1=#plg>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	local b2=#thg>0
	if not (b1 or b2) or not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	if op==1 then
		--Place 1 monster from your GY in your Spell & Trap Zone as a face-up Continuous Spell
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local plc=plg:Select(tp,1,1,nil):GetFirst()
		if not plc then return end
		Duel.BreakEffect()
		if Duel.MoveToField(plc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			--Treat it as a Continuous Spell
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
			e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
			plc:RegisterEffect(e1)
		end
	elseif op==2 then
		--Add 1 Equip or Continuous Spell from your GY to your hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local hg=thg:Select(tp,1,1,nil)
		if #hg>0 then
			Duel.HintSelection(hg)
			Duel.BreakEffect()
			Duel.SendtoHand(hg,nil,REASON_EFFECT)
		end
	end
end