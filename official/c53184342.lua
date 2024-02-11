--ドラグニティアームズ－グラム
--Dragunity Arma Gram
--Scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special summon procedure (from hand or GY)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Negate targeted monster's effects, also loses ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	--Equip an opponent's monster destroyed by battle to this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.eqpcon)
	e3:SetTarget(s.eqptg)
	e3:SetOperation(s.eqpop)
	c:RegisterEffect(e3)
	aux.AddEREquipLimit(c,nil,aux.FilterBoolFunction(Card.IsMonster),Card.EquipByEffectAndLimitRegister,e3)
end
function s.spfilter(c)
	return c:IsRace(RACE_WINGEDBEAST|RACE_DRAGON) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,e:GetHandler())
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and #rg>1
		and aux.SelectUnselectGroup(rg,e,tp,2,2,aux.ChkfMMZ(1),0) end
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,aux.ChkfMMZ(1),1,tp,HINTMSG_REMOVE)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.distg(c,eqpc)
	return c:IsNegatableMonster() or (eqpc and c:IsFaceup() and c:GetAttack()>0)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local eqpc=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_EQUIP),tp,LOCATION_ONFIELD,0,1,nil)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.distg(chkc,eqpc) end
	if chk==0 then return Duel.IsExistingTarget(s.distg,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,eqpc) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,s.distg,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,eqpc)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:IsCanBeDisabledByEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsType,TYPE_EQUIP),tp,LOCATION_SZONE,0,nil)
	if ct>0 then
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_UPDATE_ATTACK)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(-ct*1000)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
end
function s.eqpfilter(c,tp)
	return c:IsMonster() and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
		and c:IsPreviousControler(1-tp) and s.exfilter(c,tp)
end
function s.exfilter(c,tp)
	return not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.eqpcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.eqpfilter,1,nil,tp)
end
function s.eqptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local eqg=eg:Filter(s.eqpfilter,nil,tp)
	if chk==0 then return #eqg>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>=#eqg end
	Duel.SetTargetCard(eqg)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,eqg,1,0,0)
end
function s.eqpop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<1 then return end
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e):Filter(s.exfilter,nil,tp)
	if c:IsFaceup() and c:IsRelateToEffect(e) and #tg>0 and ft>0 then
		local eqg=nil
		if #tg>ft then
			eqg=tg:Select(tp,ft,ft,nil)
		else
			eqg=tg
		end
		for tc in eqg:Iter() do
			if Duel.Equip(tp,tc,c,true,true) then
				--Equip limit
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				e1:SetValue(s.eqlimit)
				tc:RegisterEffect(e1)
			end
		end
		Duel.EquipComplete()
	end
end
function s.eqlimit(e,c)
	return e:GetOwner()==c
end