--魔法の歯車
--Spell Gear
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		s[0]={}
		aux.AddValuesReset(function()
			for _,te in ipairs(s[0]) do
				if Duel.GetTurnPlayer()==te:GetOwnerPlayer() then
					s.reset(te,te:GetOwnerPlayer(),nil,0,0,nil,0,0)
				end
			end
		end)
	end)
end
s.listed_series={0x7}
s.listed_names={83104731}
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then
		e:SetLabel(1)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3 and #tg>=3 and aux.SelectUnselectGroup(tg,e,tp,3,3,aux.ChkfMMZ(1),0)
	end
	local c=e:GetHandler()
	local g=aux.SelectUnselectGroup(tg,e,tp,3,3,aux.ChkfMMZ(1),1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(g,REASON_COST)
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_SELF_TURN+RESET_PHASE+PHASE_END,2)
	e1:SetTargetRange(1,0)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	Duel.RegisterEffect(e2,tp)
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetReset(RESET_SELF_TURN+RESET_PHASE+PHASE_END,2)
	e4:SetTargetRange(1,0)
	Duel.RegisterEffect(e4,tp)
	local descnum=tp==c:GetOwner() and 0 or 1
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetDescription(aux.Stringid(id,descnum))
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(1082946)
	e3:SetOwnerPlayer(tp)
	e3:SetLabel(0)
	e3:SetOperation(s.reset)
	e3:SetReset(RESET_SELF_TURN+RESET_PHASE+PHASE_END,2)
	c:RegisterEffect(e3)
	table.insert(s[0],e3)
	s[0][e3]={e1,e2}
end
function s.reset(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local label=e:GetLabel()
	label=label+1
	e:SetLabel(label)
	if ev==1082946 then
		c:SetTurnCounter(label)
	end
	c:SetTurnCounter(0)
	if label==2 then
		local e1,e2=table.unpack(s[0][e])
		e:Reset()
		if e1 then e1:Reset() end
		if e2 then e2:Reset() end
		s[0][e]=nil
		for i,te in ipairs(s[0]) do
			if te==e then
				table.remove(s[0],i)
				break
			end
		end
	end
end
function s.filter(c,e,tp)
	return c:IsCode(83104731) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.dfilter(c)
	return c:IsFacedown() or c:GetCode()~=83104731
end
function s.spcheck(sg,e,tp,mg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)<2 and sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<2
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>2 then ft=2 end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)<=0 
		or g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=0 then ft=1 end
	local sg=aux.SelectUnselectGroup(g,e,tp,ft,ft,s.spcheck,1,tp,HINTMSG_SPSUMMON)
	if Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)>0 then
		local dg=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_MZONE,0,nil)
		if #dg>0 then
			Duel.BreakEffect()
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
