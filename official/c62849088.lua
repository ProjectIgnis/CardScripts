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
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMING_SUMMON|TIMING_SPSUMMON)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Special Summon 1 monster from your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetLabel(1)
	e2:SetCondition(s.hdexcon)
	e2:SetTarget(s.hdextg)
	e2:SetOperation(s.hdexop)
	c:RegisterEffect(e2)
	--Draw 2 cards
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetLabel(2)
	c:RegisterEffect(e3)
	--Destroy 1 of those monsters Special Summoned from the Extra Deck
	local e4=e2:Clone()
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetCode(EVENT_CUSTOM+id)
	e4:SetLabel(3)
	c:RegisterEffect(e4)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e4:SetLabelObject(g)
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
function s.spcfilter(c)
	return c:IsFaceup() and c:IsDisabled() and c:IsType(TYPE_EFFECT)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function s.hdexfilter(c,tp,loc)
	return c:IsOriginalType(TYPE_MONSTER) and c:IsSummonPlayer(1-tp) and c:IsSummonLocation(loc)
		and (loc~=LOCATION_EXTRA or c:IsOnField())
end
function s.hdexcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local label=e:GetLabel()
	if c:GetFlagEffect(id+label)>0 then return false end
	local loc=0
	if label==1 then
		loc=LOCATION_HAND
	elseif label==2 then
		loc=LOCATION_DECK
	elseif label==3 then
		loc=LOCATION_EXTRA
		eg=e:GetLabelObject()
	end
	if eg and eg:IsExists(s.hdexfilter,1,nil,tp,loc) then
		if Duel.GetCurrentChain()>0 then
			c:RegisterFlagEffect(id+label,RESET_CHAIN,0,1)
		end
		return true
	end
	return false
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.hdextg(e,tp,eg,ep,ev,re,r,rp,chk)
	local label=e:GetLabel()
	if chk==0 then
		if label==1 then
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		elseif label==2 then
			return Duel.IsPlayerCanDraw(tp,2)
		elseif label==3 then
			local g=e:GetLabelObject():Filter(s.hdexfilter,nil,tp,LOCATION_EXTRA)
			return #g>0
		end
	end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	if label==1 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	elseif label==2 then
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(2)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	elseif label==3 then
		local g=e:GetLabelObject():Filter(s.hdexfilter,nil,tp,LOCATION_EXTRA)
		Duel.SetTargetCard(g)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
end
function s.hdexop(e,tp,eg,ep,ev,re,r,rp)
	local label=e:GetLabel()
	--Special Summon effect
	if label==1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	--Draw effect
	elseif label==2 then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Draw(p,d,REASON_EFFECT)
	--Destroy effect
	elseif label==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=e:GetLabelObject():Match(Card.IsRelateToEffect,nil,e)
		g=g:FilterSelect(tp,s.hdexfilter,1,1,nil,tp,LOCATION_EXTRA)
		if #g>0 then
			Duel.HintSelection(g,true)
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>0 then return end
	local c=e:GetHandler()
	local tg=eg:Filter(s.hdexfilter,nil,tp,LOCATION_EXTRA)
	if #tg>0 and not tg:IsContains(c) then
		for tc in aux.Next(tg) do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		local g=e:GetLabelObject()
		if Duel.GetCurrentChain()==0 then g:Clear() end
		g:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
		g:Merge(tg)
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end