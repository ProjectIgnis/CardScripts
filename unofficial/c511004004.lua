--Dimension Magic
--Scripted by Edo9300
--updated by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1c0)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.filter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rfilter(c,fid)
	return c:IsReleasable() and c:GetFieldID()~=fid
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	if #tg>0 then
		local tc=tg:GetFirst()
		while tc do
			if Duel.CheckReleaseGroupCost(tp,nil,2,false,nil,tc) then
				ch=1
				tc=nil
			else
				ch=0
				tc=tg:GetNext()
			end
		end
	end
	if chk==0 then return ch==1 end
	local g1=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	local ct=#g1
	if ct>2 then
		g=Duel.SelectReleaseGroupCost(tp,nil,2,2,false,nil,nil)
	elseif ct==1 then
		g=Duel.SelectReleaseGroupCost(tp,nil,2,2,false,nil,g1:GetFirst())
	elseif ct==2 then
		g=Duel.SelectReleaseGroupCost(tp,nil,1,1,false,nil,nil)
		g1=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,g:GetFirst())
		if #g1==2 then
			g:AddCard(Duel.SelectReleaseGroupCost(tp,nil,1,1,false,nil,g:GetFirst()):GetFirst())
		else
			g:AddCard(Duel.SelectReleaseGroupCost(tp,s.rfilter,1,1,false,nil,g:GetFirst(),g1:GetFirst():GetFieldID()):GetFirst())
		end
	end
	Duel.Release(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil,e,tp)
	Duel.SetOperationInfo(g,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #sg>0 then
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
			local fid=e:GetHandler():GetFieldID()
			sg:KeepAlive()
			sg:GetFirst():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCategory(CATEGORY_TOHAND)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetRange(LOCATION_MZONE)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetLabel(fid)
			e1:SetLabelObject(sg)
			e1:SetCondition(s.rmcon)
			e1:SetOperation(s.rmop)
			Duel.RegisterEffect(e1,tp)
			if Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_MZONE,0,2,nil,RACE_SPELLCASTER) 
				and Duel.IsExistingMatchingCard(Card.IsDestructable,tp,0,LOCATION_MZONE,1,nil) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local tg=Duel.SelectMatchingCard(tp,Card.IsDestructable,tp,0,LOCATION_MZONE,1,1,nil)
				Duel.HintSelection(tg)
				local dg=Group.CreateGroup()
				local tc=tg:GetFirst()
				if tc:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) then
					local bdind={tc:GetCardEffect(EFFECT_INDESTRUCTABLE_BATTLE)}
					for i=1,#bdind do
						local te=bdind[i]
						local f=te:GetValue()
						if type(f)=='function' then
							if not f(te,tc) then dg:AddCard(tc) end
						end
					end
				else dg:AddCard(tc)
				end
				if #dg>0 then
					e:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
					local edind,val={},{}
					if tc:IsHasEffect(EFFECT_INDESTRUCTABLE_EFFECT) then
						edind={tc:GetCardEffect(EFFECT_INDESTRUCTABLE_EFFECT)}
						for i=1,#edind do
							local te=edind[i]
							val[i]=te:GetValue()
							te:SetValue(0)
						end
					end
					Duel.Destroy(dg,REASON_BATTLE)
					e:SetProperty(0)
					if #edind>0 then
						for i=1,#edind do
							edind[i]:SetValue(val[i])
						end
					end
				else
					Duel.Hint(HINT_CARD,tp,tc:GetCode())
					Duel.Hint(HINT_CARD,1-tp,tc:GetCode())
				end
			end
		end
	end
end
function s.rmfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.rmfilter,nil,e:GetLabel())
	Duel.SendtoHand(tg,tg:GetFirst():GetOwner(),REASON_EFFECT)
end