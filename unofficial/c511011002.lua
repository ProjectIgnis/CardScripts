--クレスト・バーン
--Crest Burn
--Scripted by Keddy
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_LEAVE_FIELD_P)
		ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={100000370,111215001}
function s.cfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp)
		and c:GetFlagEffectLabel(id) and c:GetFlagEffectLabel(id)>0
end
function s.filter(c)
	return c:IsFaceup() and c:IsCode(111215001)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.cfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	local ct=eg:Filter(s.cfilter,nil,tp):GetSum(Card.GetFlagEffectLabel,id)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0x1110,ct)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetChainInfo(ev,CHAININFO_TARGET_PARAM)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil)
	if #g<=0 then return end
	if #g==1 then
		local sc=Duel.GetFirstMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,nil)
		Duel.HintSelection(Group.FromCards(sc))
		sc:AddCounter(0x1110,ct)
	else
		while #g>1 and ct>0 do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local sg=g:Select(tp,1,1,nil)
			local sc=sg:GetFirst()
			local t={}
			for i=1,ct do
				t[i]=i
			end
			local tempct=Duel.AnnounceNumber(tp,table.unpack(t))
			ct=ct-tempct
			Duel.HintSelection(sg)
			sc:AddCounter(0x1110,tempct)
			g:RemoveCard(sc)
		end
		if #g==1 and ct>0 then
			local sc=g:GetFirst()
			Duel.HintSelection(g)
			sc:AddCounter(0x1110,ct)
		end
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsCode,nil,100000370)
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_LEAVE-RESET_TOGRAVE,0,1,tc:GetCounter(0x95))
	end
	if re then
		Duel.RaiseEvent(g,EVENT_CUSTOM+id,re,r,rp,ep,ev)
	else
		Duel.RaiseEvent(g,EVENT_CUSTOM+id,e,r,rp,ep,ev)
	end
end