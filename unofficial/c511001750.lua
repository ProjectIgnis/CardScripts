--緊急回避
--Emergency Evasion
local s,id=GetID()
function s.initial_effect(c)
	--Banish all cards you control when your opponent activates a Spell Card
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(function(_,_,_,_,_,re,_,_) return re:IsSpellEffect() and re:IsHasType(EFFECT_TYPE_ACTIVATE) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,0,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,0,nil)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		local rg=Duel.GetOperatedGroup()
		rg:KeepAlive()
		local tc=rg:GetFirst()
		while tc do
			tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
			tc=rg:GetNext()
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetCountLimit(1)
		e1:SetLabelObject(rg)
		e1:SetCondition(function(e) local tp=e:GetHandlerPlayer() return Duel.IsPlayerCanDraw(tp,1) end) 
		e1:SetOperation(s.drop)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.retfilter(c,tp,tpe)
	return c:HasFlagEffect(id) and c:IsLocation(LOCATION_REMOVED) and c:IsType(tpe)
		and (Duel.GetLocationCount(tp,c:GetPreviousLocation())>0 or c:IsType(TYPE_FIELD))
end
function s.drop(e,tp,eg,ep,ev,re,r,rp,c,og)
	local g=e:GetLabelObject()
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	Duel.Hint(HINT_CARD,0,id)
	Duel.Draw(tp,1,REASON_EFFECT)
	if tc and not tc:IsPublic() then
		Duel.ConfirmCards(1-tp,tc)
		local tpe=0
		if tc:IsMonster() then
			tpe=TYPE_MONSTER
		elseif tc:IsSpell() then
			tpe=TYPE_SPELL
		elseif tc:IsTrap() then
			tpe=TYPE_TRAP
		else
			return
		end
		if g:IsExists(s.retfilter,1,nil,tp,tpe) then
			local rg=g:FilterSelect(tp,s.retfilter,1,1,nil,tp,tpe)
			Duel.HintSelection(rg)
			local rc=rg:GetFirst()
			local loc=rc:GetPreviousLocation()
			local pos=rc:GetPreviousPosition()
			if (rc:GetType()&TYPE_FIELD) then
				loc=LOCATION_FZONE
				local of=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
				if of then Duel.Destroy(of,REASON_RULE) end
				of=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
				if of and Duel.Destroy(of,REASON_RULE)==0 and Duel.SendtoGrave(of,REASON_RULE)==0 then
					Duel.SendtoGrave(rc,REASON_RULE)
				end
			end
			Duel.MoveToField(rc,tp,tp,loc,pos,true)
		end
		Duel.ShuffleHand(tp)
	end
	g:DeleteGroup()
	return
end
