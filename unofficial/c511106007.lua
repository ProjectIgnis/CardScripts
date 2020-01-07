--ハイドライブ・サイクル
--Hydradrive Cycle (Anime)
--scripted by Hatter

local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetCondition(s.tkcon)
	e2:SetCost(s.tkcost)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
end
function s.filter(c,e,tp)
	return c:IsPreviousControler(tp) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP))
end
function s.exfilter(c)
	return c:IsLinkMonster() and c:IsSetCard(0x577) and c:IsAbleToExtra()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	return eg:IsExists(s.filter,1,nil,e,tp)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x577) and c:IsLinkMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		if Duel.SendtoDeck(g,tp,0,REASON_EFFECT)~=0 then
			if #g==1 then
				local dr=g:GetFirst():GetLink()
				if Duel.IsPlayerCanDraw(tp,dr) then
					if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
						Duel.BreakEffect()
						Duel.Draw(tp,dr,REASON_EFFECT)
					end
				end
			end
			if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and 
			Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and 
			Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
				if #sg>0 then
					Duel.BreakEffect()
					if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
						local sp=sg:GetFirst()
						local e1=Effect.CreateEffect(e:GetHandler())
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetCode(EFFECT_SET_ATTACK)
						e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
						e1:SetValue(0)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD)
						sp:RegisterEffect(e1,true)
					end
				end
			end
		end
	end
end
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1
end
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,400) end
	Duel.PayLPCost(tp,400)
	Duel.Hint(HINT_SELECTMSG,tp,563)
	local aat=Duel.AnnounceAttribute(tp,1,0xf)
	e:SetLabel(aat)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tu=Duel.GetTurnPlayer()
	if chk==0 then return Duel.GetLocationCount(tu,LOCATION_MZONE)>0  
		and Duel.IsPlayerCanSpecialSummonMonster(tp,511009710,0x577,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_EARTH,POS_FACEUP,tu) end	
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tu,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tu,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
 	local tu=Duel.GetTurnPlayer()
	if e:GetHandler():IsRelateToEffect(e) and
	 Duel.GetLocationCount(tu,LOCATION_MZONE)>0 and
	  Duel.IsPlayerCanSpecialSummonMonster(tp,511009710,0x577,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_EARTH,POS_FACEUP,tu) then
		local token=Duel.CreateToken(tu,511009710)
		if Duel.SpecialSummon(token,0,tp,tu,false,false,POS_FACEUP)~=0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(e:GetLabel())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1)
		end
	end
end
