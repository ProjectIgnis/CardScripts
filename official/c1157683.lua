--サイバーダーク・インヴェイジョン
--Cyberdark Invasion
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(65)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1)
	e2:SetTarget(s.target)
	c:RegisterEffect(e2)
end
s.listed_series={SET_CYBERDARK}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	end
	local b1=s.eqtg(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=s.destg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then
		return b1 or b2
	end
	s.select(e,tp,b1,b2)
end
function s.select(e,tp,b1,b2)
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))+1
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))+1
	elseif b2 then op=Duel.SelectOption(tp,aux.Stringid(id,1))+2 end
	if op==1 then
		--Equip 1 Dragon or Machine to your "Cyberdark"
		e:SetCategory(CATEGORY_EQUIP)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		s.eqtg(e,tp,eg,ep,ev,re,r,rp,1)
		e:SetOperation(s.eqop)
	elseif op==2 then
		--Destroy 1 card the opponent controls
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(0)
		s.destg(e,tp,eg,ep,ev,re,r,rp,1)
		e:SetOperation(s.desop)
	end
end
function s.eqfilter1(c)
	return c:IsFaceup() and c:IsSetCard(SET_CYBERDARK) and c:IsType(TYPE_EFFECT) 
		and Duel.IsExistingMatchingCard(s.eqfilter2,0,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
end
function s.eqfilter2(c)
	return c:IsRace(RACE_DRAGON|RACE_MACHINE) and c:IsMonster() and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter1(chkc) end
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
		and Duel.IsExistingTarget(s.eqfilter1,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.eqfilter1,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,PLAYER_EITHER,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local ec=Duel.GetFirstTarget()
	if ec and ec:IsRelateToEffect(e) and ec:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter2),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
		local tc=g:GetFirst()
		if not tc or not Duel.Equip(tp,tc,ec,true) then return end
		--Equip limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(ec)
		tc:RegisterEffect(e1)
		--Increase ATK
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(1000)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.descfilter(c)
	local ec=c:GetEquipTarget()
	return ec and ec:IsRace(RACE_MACHINE) and c:IsAbleToGraveAsCost()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(s.descfilter,tp,LOCATION_SZONE,0,nil)
	local dg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return Duel.GetFlagEffect(tp,id+1)==0 and #mg>0 and #dg>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=mg:Select(tp,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
	Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end