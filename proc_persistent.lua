
--add procedure to persistent traps
function Auxiliary.AddPersistentProcedure(c,p,f,category,property,hint1,hint2,con,cost,tg,op,anypos)
	--Note: p==0 is check persistent trap controler, p==1 for opponent's, PLAYER_ALL for both player's monsters
	--anypos is check for face-up/any
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1068)
	if category then
		e1:SetCategory(category)
	end
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	if hint1 or hint2 then
		if hint1==hint2 then
			e1:SetHintTiming(hint1)
		elseif hint1 and not hint2 then
			e1:SetHintTiming(hint1,0)
		elseif hint2 and not hint1 then
			e1:SetHintTiming(0,hint2)
		else
			e1:SetHintTiming(hint1,hint2)
		end
	end
	if property then
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET+property)
	else
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	end
	if con then
		e1:SetCondition(con)
	end
	if cost then
		e1:SetCost(cost)
	end
	e1:SetTarget(Auxiliary.PersistentTarget(tg,p,f))
	e1:SetOperation(Auxiliary.PersistentOperation(anypos,op))
	c:RegisterEffect(e1)
end
function Auxiliary.PersistentFilter(c,p,f,e,tp,tg,eg,ep,ev,re,r,rp)
	return (p==PLAYER_ALL or c:IsControler(p)) and (not f or f(c,e,tp)) and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,c,0))
end
function Auxiliary.PersistentTarget(tg,p,f)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
				local player=nil
				if p==0 then
					player=tp
				elseif p==1 then
					player=1-tp
				elseif p==PLAYER_ALL or p==nil then
					player=PLAYER_ALL
				end
				if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and Auxiliary.PersistentFilter(chkc,player,f,e,tp) end
				if chk==0 then return Duel.IsExistingTarget(Auxiliary.PersistentFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,player,f,e,tp,tg,eg,ep,ev,re,r,rp)
					and player~=nil end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
				local g=Duel.SelectTarget(tp,Auxiliary.PersistentFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,player,f,e,tp)
				if tg then tg(e,tp,eg,ep,ev,re,r,rp,g:GetFirst(),1) end
			end
end
function Auxiliary.PersistentOperation(anypos,op)
	return	function(e,tp,eg,ep,ev,re,r,rp)
			local tc=Duel.GetFirstTarget()
			if (anypos or tc:IsFaceup()) and tc:IsRelateToEffect(e) then
				local c=e:GetHandler()
				c:SetCardTarget(tc)
				c:CreateRelation(tc,RESET_EVENT|RESETS_STANDARD)
			end
			if op then op(e,tp,eg,ep,ev,re,r,rp) end
		end
end
function Auxiliary.PersistentTargetFilter(e,c)
	return e:GetHandler():IsHasCardTarget(c)
end
