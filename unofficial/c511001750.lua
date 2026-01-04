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
		for tc in rg:Iter() do
			tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EVENT_CHAIN_END)
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
			local rg=g:Filter(Card.IsType,nil,tpe)
			for rc in rg:Iter() do
				if rc:IsPreviousLocation(LOCATION_PZONE) then
					local seq=0
					if rc:GetPreviousSequence()==7 or rc:GetPreviousSequence()==4 then seq=1 end
					Duel.MoveToField(rc,tp,tp,LOCATION_PZONE,rc:GetPreviousPosition(),true,(1<<seq))
				elseif rc:IsPreviousLocation(LOCATION_FZONE) and rc:IsFieldSpell() then
					Duel.MoveToField(rc,tp,tp,LOCATION_FZONE,rc:GetPreviousPosition(),true)
				else
					Duel.MoveToField(rc,tp,tp,rc:GetPreviousLocation(),rc:GetPreviousPosition(),true)
					if not rc:IsContinuousSpellTrap() and rc:IsPosition(POS_FACEUP) and not rc:IsHasEffect(EFFECT_REMAIN_FIELD) then
						Duel.SendtoGrave(rc,REASON_RULE)
					end
				end
			end
		end
		g:DeleteGroup()
	end	
end
