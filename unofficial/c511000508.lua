--マアト (manga)
--Ma'at (manga)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Material: "Winged Kuriboh" + "Light and Darkness Dragon"
	Fusion.AddProcMix(c,true,true,57116033,47297616)
	--Declare 1 card name, then draw 1 card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return not e:GetHandler():HasFlagEffect(id+100) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
	--This card's ATK becomes the number of cards drawn by the above effect x 1000
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetValue(function(e,c) return e:GetHandler():GetFlagEffect(id)*1000 end)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e3)
end
s.material_setcode=SET_KURIBOH
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local g=Duel.GetDecktopGroup(tp,1)
		local tc=g:GetFirst()
		if Duel.Draw(tp,1,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,tc)
			c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,0)
			if tc:IsCode(ac) then
				if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and tc:IsSpellTrap() and tc:CheckActivateEffect(false,false,false)~=nil 
					and not tc:IsHasEffect(EFFECT_CANNOT_TRIGGER) and not tc:IsForbidden() and Duel.SelectEffectYesNo(tp,tc) then
					local tpe=tc:GetType()
					local te=tc:GetActivateEffect()
					if not te then return end
					local pre={Duel.GetPlayerEffect(tp,EFFECT_CANNOT_ACTIVATE)}
					if pre[1] then
						for i,eff in ipairs(pre) do
							local prev=eff:GetValue()
							if type(prev)~='function' or prev(eff,te,tp) then return end
						end
					end
					local tg=te:GetTarget()
					local co=te:GetCost()
					local op=te:GetOperation()
					e:SetCategory(te:GetCategory())
					e:SetProperty(te:GetProperty())
					Duel.ClearTargetCard()
					Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
					Duel.Hint(HINT_CARD,0,tc:GetOriginalCode())
					tc:CreateEffectRelation(te)
					if (tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 and not tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
						tc:CancelToGrave(false)
					end
					if te:GetCode()==EVENT_CHAINING then
						local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
						local tc=te2:GetHandler()
						local g=Group.FromCards(tc)
						local p=tc:GetControler()
						if co then co(te,tp,g,p,chain,te2,REASON_EFFECT,p,1) end
						if tg then tg(te,tp,g,p,chain,te2,REASON_EFFECT,p,1) end
					elseif te:GetCode()==EVENT_FREE_CHAIN then
						if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
						if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
					else
						local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
						if co then co(te,tp,teg,tep,tev,tre,tr,trp,1) end
						if tg then tg(te,tp,teg,tep,tev,tre,tr,trp,1) end
					end
					Duel.BreakEffect()
					local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
					if g then
						local etc=g:GetFirst()
						while etc do
							etc:CreateEffectRelation(te)
							etc=g:GetNext()
						end
					end
					tc:SetStatus(STATUS_ACTIVATED,true)
					if not tc:IsDisabled() then
						if te:GetCode()==EVENT_CHAINING then
							local te2=Duel.GetChainInfo(chain,CHAININFO_TRIGGERING_EFFECT)
							local tc=te2:GetHandler()
							local g=Group.FromCards(tc)
							local p=tc:GetControler()
							if op then op(te,tp,g,p,chain,te2,REASON_EFFECT,p) end
						elseif te:GetCode()==EVENT_FREE_CHAIN then
							if op then op(te,tp,eg,ep,ev,re,r,rp) end
						else
							local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(te:GetCode(),true)
							if op then op(te,tp,teg,tep,tev,tre,tr,trp) end
						end
					else
						--insert negated animation here
					end
					Duel.RaiseEvent(Group.CreateGroup(tc),EVENT_CHAIN_SOLVED,te,0,tp,tp,Duel.GetCurrentChain())
					if g and tc:IsType(TYPE_EQUIP) and not tc:GetEquipTarget() then
						Duel.Equip(tp,tc,g:GetFirst())
					end
					tc:ReleaseEffectRelation(te)
					if etc then
						etc=g:GetFirst()
						while etc do
							etc:ReleaseEffectRelation(te)
							etc=g:GetNext()
						end
					end
				elseif tc:IsMonster() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
					Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
				end
			else
				c:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD,0,0)
			end
		end
	end
end
