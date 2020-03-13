if not aux.LinkProcedure then
	aux.LinkProcedure = {}
	Link = aux.LinkProcedure
end
if not Link then
	Link = aux.LinkProcedure
end
--Link Summon
function Link.AddProcedure(c,f,min,max,specialchk,desc)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	if desc then
		e1:SetDescription(desc)
	else
		e1:SetDescription(1174)
	end
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	if max==nil then max=c:GetLink() end
	e1:SetCondition(Link.Condition(f,min,max,specialchk))
	e1:SetTarget(Link.Target(f,min,max,specialchk))
	e1:SetOperation(Link.Operation(f,min,max,specialchk))
	e1:SetValue(SUMMON_TYPE_LINK)
	c:RegisterEffect(e1)
end
function Link.ConditionFilter(c,f,lc,tp)
	return c:IsCanBeLinkMaterial(lc,tp) and (not f or f(c,lc,SUMMON_TYPE_LINK|MATERIAL_LINK,tp))
end
function Link.GetLinkCount(c)
	if c:IsLinkMonster() and c:GetLink()>1 then
		return 1+0x10000*c:GetLink()
	else return 1 end
end
function Link.CheckRecursive(c,tp,sg,mg,lc,minc,maxc,f,specialchk,og,emt,filt)
	if #sg>maxc then return false end
	filt=filt or {}
	local oldfilt={table.unpack(filt)}
	sg:AddCard(c)
	for _,f in ipairs(filt) do
		if not f[2](c,f[3],tp,sg,mg,lc,f[1],1) then
			sg:RemoveCard(c)
			return false
		end
	end
	if not og:IsContains(c) then
		res=aux.CheckValidExtra(c,tp,sg,mg,lc,emt,filt)
		if not res then
			sg:RemoveCard(c)
			filt={table.unpack(oldfilt)}
			return false
		end
	end
	local res=Link.CheckGoal(tp,sg,lc,minc,f,specialchk,filt)
		or (#sg<maxc and mg:IsExists(Link.CheckRecursive,1,sg,tp,sg,mg,lc,minc,maxc,f,specialchk,og,emt,filt))
	sg:RemoveCard(c)
	filt={table.unpack(oldfilt)}
	return res
end
function Link.CheckRecursive2(c,tp,sg,sg2,secondg,mg,lc,minc,maxc,f,specialchk,og,emt,filt)
	if #sg>maxc then return false end
	local oldfilt={table.unpack(filt)}
	sg:AddCard(c)
	for _,f in ipairs(filt) do
		if not f[2](c,f[3],tp,sg,mg,lc,f[1],1) then
			sg:RemoveCard(c)
			return false
		end
	end
	if not og:IsContains(c) then
		res=aux.CheckValidExtra(c,tp,sg,mg,lc,emt,filt)
		if not res then
			sg:RemoveCard(c)
			filt={table.unpack(oldfilt)}
			return false
		end
	end
	if #(sg2-sg)==0 then
		if secondg and #secondg>0 then
			local res=secondg:IsExists(Link.CheckRecursive,1,sg,tp,sg,mg,lc,minc,maxc,f,specialchk,og,emt,{table.unpack(filt)})
			sg:RemoveCard(c)
			return res
		else
			local res=Link.CheckGoal(tp,sg,lc,minc,f,specialchk,{table.unpack(filt)})
			sg:RemoveCard(c)
			return res
		end
	end
	local res=Link.CheckRecursive2((sg2-sg):GetFirst(),tp,sg,sg2,secondg,mg,lc,minc,maxc,f,specialchk,og,emt,filt)
	sg:RemoveCard(c)
	return res
end
function Link.CheckGoal(tp,sg,lc,minc,f,specialchk,filt)
	for _,f in ipairs(filt) do
		if not sg:IsExists(f[2],1,nil,f[3],tp,sg,Group.CreateGroup(),lc,f[1],1) then
			return false
		end
	end
	return #sg>=minc and sg:CheckWithSumEqual(Link.GetLinkCount,lc:GetLink(),#sg,#sg)
		and (not specialchk or specialchk(sg,lc,tp)) and Duel.GetLocationCountFromEx(tp,tp,sg,lc)>0
end
function Link.Condition(f,minc,maxc,specialchk)
	return	function(e,c,must,g,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				if not g then
					g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
				end
				local mg=g:Filter(Link.ConditionFilter,nil,f,c,tp)
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_LINK)
				if must then mustg:Merge(must) end
				if min and min < minc then return false end
				if max and max > maxc then return false end
				min = min or minc
				max = max or maxc
				if mustg:IsExists(aux.NOT(Link.ConditionFilter),1,nil,f,c,tp) or #mustg>max then return false end
				local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_LINK)
				local res=(mg+tg):Includes(mustg) and #mustg<=max
				if res then
					if #mustg==max then
						local sg=Group.CreateGroup()
						res=mustg:IsExists(Link.CheckRecursive,1,sg,tp,sg,(mg+tg),c,min,max,f,specialchk,mg,emt)
					elseif #mustg<max then
						local sg=mustg
						res=(mg+tg):IsExists(Link.CheckRecursive,1,sg,tp,sg,(mg+tg),c,min,max,f,specialchk,mg,emt)
					end
				end
				aux.DeleteExtraMaterialGroups(emt)
				return res
			end
end
function Link.Target(f,minc,maxc,specialchk)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,must,g,min,max)
				if not g then
					g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
				end
				if min and min < minc then return false end
				if max and max > maxc then return false end
				min = min or minc
				max = max or maxc
				local mg=g:Filter(Link.ConditionFilter,nil,f,c,tp)
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_LINK)
				if must then mustg:Merge(must) end
				local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_LINK)
				local sg=Group.CreateGroup()
				local finish=false
				local cancel=false
				sg:Merge(mustg)
				while #sg<max do
					local filters={}
					if #sg>0 then
						Link.CheckRecursive2(sg:GetFirst(),tp,Group.CreateGroup(),sg,mg+tg,mg+tg,c,min,max,f,specialchk,mg,emt,filters)
					end
					local cg=(mg+tg):Filter(Link.CheckRecursive,sg,tp,sg,(mg+tg),c,min,max,f,specialchk,mg,emt,filters)
					if #cg==0 then break end
					finish=#sg>=min and #sg<=max and Link.CheckGoal(tp,sg,c,min,f,specialchk,filters)
					cancel=not og and Duel.GetCurrentChain()<=0 and #sg==0
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LMATERIAL)
					local tc=Group.SelectUnselect(cg,sg,tp,finish,cancel,1,1)
					if not tc then break end
					if #mustg==0 or not mustg:IsContains(tc) then
						if not sg:IsContains(tc) then
							sg:AddCard(tc)
						else
							sg:RemoveCard(tc)
						end
					end
				end
				if #sg>0 then
					local filters={}
					Link.CheckRecursive2(sg:GetFirst(),tp,Group.CreateGroup(),sg,mg+tg,mg+tg,c,min,max,f,specialchk,mg,emt,filters)
					sg:KeepAlive()
					local reteff=Effect.GlobalEffect()
					reteff:SetTarget(function()return sg,filters,emt end)
					e:SetLabelObject(reteff)
					return true
				else 
					aux.DeleteExtraMaterialGroups(emt)
					return false
				end
			end
end
function Link.Operation(f,minc,maxc,specialchk)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,must,g,min,max)
				local g,filt,emt=e:GetLabelObject():GetTarget()()
				e:GetLabelObject():Reset()
				for _,ex in ipairs(filt) do
					if ex[3]:GetValue() then
						ex[3]:GetValue()(1,SUMMON_TYPE_LINK,ex[3],ex[1]&g,c,tp)
					end
				end
				c:SetMaterial(g)
				Duel.SendtoGrave(g,REASON_MATERIAL+REASON_LINK)
				g:DeleteGroup()
				aux.DeleteExtraMaterialGroups(emt)
			end
end
