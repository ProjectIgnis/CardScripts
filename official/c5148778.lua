--覇王暴竜スターヴ・ヴェノム・ウィング・ドラゴン
--Starving Venom Wing Dragon
--Scripted By The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c,false)
	--Fusion Materials: 1 Fusion Monster + 1 "Clear Wing" monster
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsType,TYPE_FUSION),aux.FilterBoolFunctionEx(Card.IsSetCard,SET_CLEAR_WING))
	--Place Predator Counters on monsters Special Summoned to your opponent's field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetOperation(s.counterplaceop)
	c:RegisterEffect(e1)
	--If your opponent Special Summons a monster(s): You can target 1 of them; this card gains ATK equal to its ATK, and its effects are negated.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.atknegeffcon)
	e2:SetTarget(s.atknegefftg)
	e2:SetOperation(s.atknegeffop)
	c:RegisterEffect(e2)
	--When another card or effect is activated on the field: You can destroy 1 card on the field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return re:GetHandler()~=e:GetHandler() and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)&LOCATION_ONFIELD>0 end)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	--Place itself into Pendulum Zone if it is destroyed
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) end)
	e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return Duel.CheckPendulumZones(tp) end local c=e:GetHandler() if c:IsLocation(LOCATION_GRAVE) then Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0) end end)
	e4:SetOperation(s.penop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_CLEAR_WING}
s.material_setcode={SET_CLEAR_WING}
s.counter_place_list={COUNTER_PREDATOR}
function s.counterplaceop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(Card.IsControler,nil,1-tp)
	for tc in g:Iter() do
		if tc:AddCounter(COUNTER_PREDATOR,1) and tc:IsLevelAbove(2) then
			--It becomes Level 1 as long as it has a Predator Counter
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetCondition(function(e) return e:GetHandler():HasCounter(COUNTER_PREDATOR) end)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
function s.atknegefffilter(c,e,tp)
	return c:IsSummonPlayer(1-tp) and c:IsCanBeEffectTarget(e)	and c:IsLocation(LOCATION_MZONE) and c:HasNonZeroAttack()
end
function s.atknegeffcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.atknegefffilter,1,nil,e,tp)
end
function s.atknegefftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and s.atknegefffilter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(s.atknegefffilter,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tc=nil
	if #eg==1 then
		tc=eg:GetFirst()
		Duel.SetTargetCard(tc)
	else
		tc=eg:FilterSelect(tp,s.atknegefffilter,1,1,nil,e,tp)
		Duel.SetTargetCard(tc)
	end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,0,0)
end
function s.atknegeffop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup()
		and c:UpdateAttack(tc:GetAttack(),RESETS_STANDARD_DISABLE_PHASE_END) and tc:IsNegatableMonster() then
		tc:NegateEffects(c,RESETS_STANDARD_PHASE_END)
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD),1,tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end