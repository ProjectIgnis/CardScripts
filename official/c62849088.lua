--妖眼の相剣師
--The Iris Swordsoul
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_SUMMON+TIMING_SPSUMMON)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Special Summon from hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetLabel(LOCATION_HAND)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.hdextg)
	e2:SetOperation(s.hdexop)
	c:RegisterEffect(e2)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e2:SetLabelObject(g)
	--Draw 2
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetLabel(LOCATION_DECK)
	c:RegisterEffect(e3)
	--Destroy
	local e4=e2:Clone()
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetLabel(LOCATION_EXTRA)
	c:RegisterEffect(e4)
	--Register summons
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetLabelObject(g)
	e5:SetOperation(s.regop)
	c:RegisterEffect(e5)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsDisabled),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function s.hdexfilter(c,tp,loc)
	return c:IsSummonPlayer(1-tp) and c:IsSummonLocation(loc) and (loc~=LOCATION_EXTRA or c:IsOnField())
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.hdextg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=e:GetLabel()
	local g=e:GetLabelObject():Filter(s.hdexfilter,nil,tp,loc)
	if loc==LOCATION_HAND then
		if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	elseif loc==LOCATION_DECK then
		if chk==0 then return #g>0 and Duel.IsPlayerCanDraw(tp,2) end
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	elseif loc==LOCATION_EXTRA then
		if chk==0 then return #g>0 end
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	end
end
function s.hdexop(e,tp,eg,ep,ev,re,r,rp)
	local loc=e:GetLabel()
	--Special Summon effect
	if loc==LOCATION_HAND then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	--Draw effect
	elseif loc==LOCATION_DECK then
		Duel.Draw(tp,2,REASON_EFFECT)
	--Destroy effect
	elseif loc==LOCATION_EXTRA then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=e:GetLabelObject():FilterSelect(tp,s.hdexfilter,1,1,nil,tp,LOCATION_EXTRA)
		if #g>0 then
			Duel.HintSelection(g,true)
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=eg:Filter(s.hdexfilter,nil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)
	if #tg>0 and not tg:IsContains(c) then
		for tc in aux.Next(tg) do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		local g=e:GetLabelObject()
		if Duel.GetCurrentChain()==0 then g:Clear() end
		g:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
		g:Merge(tg)
		if Duel.GetFlagEffect(tp,id+1)==0 then
			Duel.RegisterFlagEffect(tp,id+1,RESET_CHAIN,0,1)
			Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,0)
		end
	end
end
